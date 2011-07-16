# Copyright 2006-2011 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 

  # Connect deprec:db to deprec:mysql, deprec:web to deprec:apache, etc
  on :load, 'deprec:connect_canonical_tasks' 

  # Set the value if not already set
  # This method is accessible to all recipe files
  # Defined and used by capistrano/deploy tasks
  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end

  # deprecated
  alias :default :_cset

  _cset :rake, 'rake'
  
  # Deprec checks here for local versions of config templates before it's own
  _cset :local_template_dir, File.join('config','templates')
  
  # The following two Constants contain details of the configuration 
  # files used by each service. They're used when generating config
  # files from templates and when configs files are pushed out to servers.
  #
  # They are populated by the recipe file for each service
  #
  SYSTEM_CONFIG_FILES  = {} # e.g. httpd.conf
  PROJECT_CONFIG_FILES = {} # e.g. projectname-httpd-vhost.conf
  
  # For each service, the details of the file to download and options
  # to configure, build and install the service
  SRC_PACKAGES = {} unless defined?(SRC_PACKAGES)

  # deprec defines some generic recipes for common services
  # including ruby interpreter, web, app and database servers
  #
  # They default to my current favourites which you can over ride
  #  
  # Service options
  CHOICES_RUBY_VM   = [:mri, :ree]
  CHOICES_WEBSERVER = [:apache, :none] # :nginx not recipes out of date
  CHOICES_APPSERVER = [:passenger, :none] # any colour you like guys
  CHOICES_DATABASE  = [:mysql, :postgresql, :sqlite, :none]
  # 
  # Service defaults
  _cset :ruby_vm_type,    :mri
  _cset :web_server_type, :apache
  _cset :app_server_type, :passenger
  _cset :db_server_type,  :mysql

  # Prompt user for missing values if not supplied
  _cset(:application) do
    Capistrano::CLI.ui.ask "Enter name of project(no spaces)" do |q|
      q.validate = /^[0-9a-z_]*$/
    end
  end 

  _cset(:domain) do
    Capistrano::CLI.ui.ask "Enter domain name for project" do |q|
      q.validate = /^[0-9a-z_\.]*$/
    end
  end

  _cset(:repository) do
    Capistrano::CLI.ui.ask "Enter repository URL for project" do |q|
      # q.validate = //
    end
  end

  _cset :backup_dir, '/var/backups'  

  # XXX rails deploy stuff
  _cset :apps_root,    '/srv'  # parent dir for apps
  _cset(:deploy_to)    { File.join(apps_root, application) } # dir for current app
  _cset(:current_path) { File.join(deploy_to, "current") }
  _cset(:shared_path)  { File.join(deploy_to, "shared") }

  # XXX more rails deploy stuff?

  _cset :user, ENV['USER']         # user who is deploying
  _cset :group, 'deploy'           # deployment group
  _cset(:group_src) { group }      # group ownership for src dir
  _cset :src_dir, '/usr/local/src' # 3rd party src on servers lives here
  _cset(:web_server_aliases) { domain.match(/^www/) ? [] : ["www.#{domain}"] }    

  # It can be useful to know the user running this command
  # even when USER is set to someone else. Sorry windows!
  _cset :current_user, `whoami`.chomp

  namespace :deprec do
    
    task :connect_canonical_tasks do      
      # link application specific recipes into canonical task names
      # e.g. deprec:web:restart => deprec:nginx:restart 
      
      
      namespaces_to_connect = { :web => :web_server_type,
                                :app => :app_server_type,
                                :db  => :db_server_type,
                                :ruby => :ruby_vm_type
                              }
      namespaces_to_connect.each do |server, choice|
        server_type = send(choice).to_sym
        if server_type != :none
          namespaces[server] = deprec.send(server_type)          
        end
      end
    end

    task :dump do
      require 'yaml'
      y variables
    end
    
    task :setup_src_dir do
      deprec2.groupadd(group_src)
      deprec2.add_user_to_group(user, group_src)
      deprec2.create_src_dir
    end
    
    # Download all packages used by deprec to your local host.
    # You can then push them to /usr/local/src on target hosts
    # to save time and bandwidth rather than repeatedly downloading
    # from the distribution sites.
    task :update_src do
      SRC_PACKAGES.each{|key, src_package| 
        current_dir = Dir.pwd
        system "cd src/ && test -f #{src_package[:filename]} || wget --quiet --timestamping #{src_package[:url]}"
        system "cd #{current_dir}"
      }
    end
    
    # todo
    #
    # Copy files from src/ to /usr/local/src/ on remote hosts
    task :push_src do
      SRC_PACKAGES.each do |key, src_package| 
        deprec2.set_package_defaults(src_package)
        file = File.join('src', src_package[:filename])
        if File.exists?(file)
          std.su_put(File.read(file), "#{src_dir}/#{src_package[:filename]}", '/tmp/')
        end
      end
    end
    
    task :list_src do
      # XXX ugly line - look away
      max_key_size = SRC_PACKAGES.keys.max{|a,b| a.to_s.size <=> b.to_s.size}.to_s.size
      SRC_PACKAGES.each{|key, src_package| 
        deprec2.set_package_defaults(src_package)
        puts "#{key}#{' '*(max_key_size+1-key.to_s.size)}: #{src_package[:url]}"
      }
    end
    
    task :find_src do
      # XXX ugly line - look away
      max_key_size = SRC_PACKAGES.keys.max{|a,b| a.to_s.size <=> b.to_s.size}.to_s.size
      SRC_PACKAGES.each{|key, src_package| 
        deprec2.set_package_defaults(src_package)
        puts "#{key}#{' '*(max_key_size+1-key.to_s.size)}: #{src_package[:url]}"
        puts `find . -name #{src_package[:filename]}`
        puts
      }
    end
    
    task :recover_src do
      # XXX ugly line - look away
      max_key_size = SRC_PACKAGES.keys.max{|a,b| a.to_s.size <=> b.to_s.size}.to_s.size
      SRC_PACKAGES.each{|key, src_package| 
        puts "#{key}#{' '*(max_key_size+1-key.to_s.size)}: #{src_package[:url]}"
        file = `find . -name #{src_package[:filename]}`.split[0]
        `cp #{file} src/` if file
        puts
      }
    end
     
  end
  
end
