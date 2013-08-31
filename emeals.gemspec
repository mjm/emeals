# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emeals/version'

Gem::Specification.new do |gem|
  gem.name          = "emeals"
  gem.version       = Emeals::VERSION
  gem.authors       = ["Matt Moriarity"]
  gem.email         = ["matt@mattmoriarity.com"]
  gem.description   = %q{A client for reading eMeals menus.}
  gem.summary       = %q{eMeals Client}
  gem.homepage      = "https://github.com/mjm/emeals"

  gem.add_runtime_dependency "multi_json"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
