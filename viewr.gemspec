# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'viewr/version'

Gem::Specification.new do |spec|
  spec.name          = "viewr"
  spec.version       = Viewr::VERSION
  spec.authors       = ["Ole Reifschneider"]
  spec.email         = ["mail@ole-reifschneider.de"]
  spec.description   = %q{Database view dependency resolver}
  spec.summary       = %q{Database view dependency resolver}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
