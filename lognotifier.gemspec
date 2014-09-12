# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lognotifier/version'

Gem::Specification.new do |spec|
  spec.name          = "lognotifier"
  spec.version       = Lognotifier::VERSION
  spec.authors       = ["Juan Breinlinger"]
  spec.email         = ["<juan.brein@breins.net>"]
  spec.summary       = %q{Parse logs and notify to pagerduty on patter match}
  spec.description   = %q{Log notifier will check for patterns on log files and send a notifications to pagerduty if there is a match}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
