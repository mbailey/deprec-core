# Copyright 2006-2011 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 

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

end
