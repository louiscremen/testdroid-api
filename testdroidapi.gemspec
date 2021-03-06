# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'testdroid-api/version'

Gem::Specification.new do |spec|
  spec.name          = "testdroid-api"
  spec.version       = TestdroidApi::VERSION
  spec.homepage      = "http://github.com/soundcloud/testdroid-api"

  spec.authors       = ["Slawomir Smiechura"]
  spec.email         = ["slawomir@soundcloud.com"]
  spec.description   = %q{Testdroid API client}
  spec.summary       = %q{Allows app uploads, triggers test runs and collects results.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'rake', '~>10.1.0'
  spec.add_development_dependency 'rspec', '>=2.14.1'
  spec.add_development_dependency 'yard', '>=0.8.7.2'
  spec.add_development_dependency 'simplecov', '>=0.7.1'
  spec.add_development_dependency 'coveralls', '>=0.5.8'
  spec.add_development_dependency 'webmock', '>=1.13.0'

  spec.add_dependency 'rest-client', '~>1.6.7'
end
