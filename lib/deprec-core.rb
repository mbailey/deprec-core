require "deprec-core/version"

if defined?(Capistrano)
  require "deprec-core/capistrano_extensions"
  require "vmbuilder_plugins/all"
  require "deprec-core/canonical"
  require "deprec-core/deprec"
elsif defined?(rake)
  # pass
end
