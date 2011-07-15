require "deprec-core/version"

if defined?(Capistrano)
  require "#{File.dirname(__FILE__)}/deprec-core/capistrano_extensions"
  require "#{File.dirname(__FILE__)}/vmbuilder_plugins/all"
elsif defined?(rake)
  # pass
end

module Deprec
  module Core
    # Your code goes here...
  end
end
