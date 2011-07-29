# Copyright 2006-2011 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 

  # Bundler's Capistrano tasks update this
  # Call rake within tasks using #{rake}
  _cset :rake, 'rake'
  
  # Deprec checks here for local versions of config templates before it's own
  _cset :local_template_dir, File.join('config','templates')
  
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

  # XXX We *probably* want these set
  # Must be set for the password prompt from git to work
  # default_run_options[:pty] = true  
  # ssh_options[:forward_agent] = true

  # SCM
  set :scm, "git" # This is set to :svn by Capistrano deploy recipes
  _cset :user, "deploy" 
  _cset :deploy_via, :remote_cache
  _cset :branch, "master"

  # XXX rails deploy stuff
  _cset :apps_root,    '/srv'  # parent dir for apps
  _cset(:deploy_to)    { File.join(apps_root, application) } # dir for current app
  _cset(:current_path) { File.join(deploy_to, "current") }
  _cset(:shared_path)  { File.join(deploy_to, "shared") }

  # XXX more rails deploy stuff?

  _cset :group, 'deploy'           # deployment group
  _cset(:group_src) { group }      # group ownership for src dir
  _cset :src_dir, '/usr/local/src' # 3rd party src on servers lives here
  _cset(:web_server_aliases) { domain.match(/^www/) ? [] : ["www.#{domain}"] }    

  # It can be useful to know the user running this command
  # even when USER is set to someone else. Sorry windows!
  _cset :current_user, `whoami`.chomp

  # Used by vmbuilder_plugins and Capistrano's deploy tasks
  _cset :run_method, :sudo

end
