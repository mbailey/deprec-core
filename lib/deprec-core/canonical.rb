# Copyright 2006-2008 by Mike Bailey. All rights reserved.
# canonical.rb
#
# Running deprec:web:stop will be the same as running deprec:apache:stop or 
# deprec:nginx:stop depending what you have chosen.
#
# generic namespaces are linked up to chosen applications at runtime but these
# stubs are so they'll be included in the output of "cap -T"
#
Capistrano::Configuration.instance(:must_exist).load do 

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

  # Connect deprec:db to deprec:mysql, deprec:web to deprec:apache, etc
  on :load, 'deprec:connect_canonical_tasks'

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
        if server_type != :none && deprec.respond_to?(server_type)
          namespaces[server] = deprec.send(server_type)
        end
      end
    end
  end
  
  %w(ruby).each do |package|
    namespace "deprec:#{package}" do
      
      desc "Install #{package.capitalize}"
      task :install do 
      end
      
    end
  end
  
  %w(web app db).each do |server|
    namespace "deprec:#{server}" do
      
      desc "Install #{server.capitalize} server"
      task :install, :roles => server do 
      end
      
      desc "Generate config file(s) for #{server} server from template(s)"
      task :config_gen do
      end
      
      desc "Deploy configuration files(s) for #{server} server"
      task :config, :roles => server do
      end
      
      desc "Start #{server} server"
      task :start, :roles => server do
      end
      
      desc "Stop #{server} server"
      task :stop, :roles => server do
      end
      
      desc "Stop #{server} server"
      task :restart, :roles => server do
      end
      
      desc "Enable startup script for #{server} server"
      task :activate, :roles => server do
      end  
      
      desc "Disable startup script for #{server} server"
      task :deactivate, :roles => server do
      end
      
      desc "Backup data for #{server} server"
      task :backup, :roles => server do
      end
      
      desc "Restore data for #{server} server from backup"
      task :restore, :roles => server do
      end
      
    end
  end
  
end
