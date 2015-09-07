# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'canvas/version'

Gem::Specification.new do |spec|
  spec.name          = 'canvas'
  spec.version       = Canvas::VERSION
  spec.authors       = ['Xiaoting']
  spec.email         = ['yext4011@gmail.com']
  spec.summary       = %q{For instantiating an object.}
  spec.description   = %q{Make instantiation of Class easy}
  spec.homepage      = 'https://github.com/milodky/canvas'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'andand'
end
