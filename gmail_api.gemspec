# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gmail_api/version'

Gem::Specification.new do |spec|
  spec.name          = "gmail_api"
  spec.version       = GmailApi::VERSION
  spec.authors       = ["Jose Boza"]
  spec.email         = ["jaboza@gmail.com"]
  spec.summary       = %q{Gmail API ruby wrapper}
  spec.description   = %q{Gmail API ruby wrapper}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency     "google-api-client", "~> 0.7.1"
  spec.add_runtime_dependency     'mime', '~> 0.4.2'
end
