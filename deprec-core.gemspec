# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "deprec-core/version"

Gem::Specification.new do |s|
  s.name        = "deprec-core"
  s.version     = Deprec::Core::VERSION
  s.authors     = ["Mike Bailey"]
  s.email       = ["mike@bailey.net.au"]
  s.homepage    = ""
  s.summary     = %q{deprec-core provides extensions to Capistrano}
  s.description = %q{deprec-core was extracted from the popular deprec gem to make it easier for people to publish Capistrano and Rake task gems}

  s.rubyforge_project = "deprec-core"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
