# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'handy_hash'

Gem::Specification.new do |spec|
  spec.name          = "handy_hash"
  spec.version       = HandyHash::VERSION
  spec.authors       = ["schebannyj"]
  spec.email         = ["stp.eternal@gmail.com"]

  spec.summary       = %q{HandyHash is a Hash that supply handy ways for accessing data and merging.}
  spec.description   = %q{HandyHash is a Hash object that supply handy ways for accessing data and merging.}
  spec.homepage      = "https://github.com/stp-che/handy_hash"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 5.0"  

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
