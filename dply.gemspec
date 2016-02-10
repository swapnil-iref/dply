# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dply/version'

Gem::Specification.new do |spec|
  spec.name          = "dply"
  spec.version       = Dply::VERSION
  spec.authors       = ["Neeraj"]
  spec.summary       = %q{rake based deploy tool}
  spec.description   = %q{rake based deploy tool}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency "ruby-elf", "~> 1.0"
  spec.add_dependency "ruby-filemagic", "~> 0.7"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
