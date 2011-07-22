require "deprec-core/version"

if defined?(Capistrano)
  require "vmbuilder_plugins/all"
  require "deprec-core/deprec"
  require "deprec-core/defaults"
  require "deprec-core/capistrano_extensions"
  require "deprec-core/canonical"
elsif defined?(rake)
  # pass
end
