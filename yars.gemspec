# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yars/version'

Gem::Specification.new do |spec|
  spec.name          = 'yars'
  spec.version       = Yars::VERSION
  spec.authors       = ['Ian Ker-Seymer']
  spec.email         = ['i.kerseymer@gmail.com']
  spec.summary       = 'Yet Another (Concurrent) Ruby Server.'
  spec.homepage      = 'https://github.com/ianks/yars'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split "\x0"
  spec.executables   = spec.files.grep(/^bin/) { |f| File.basename f }
  spec.test_files    = spec.files.grep(/^spec/)
  spec.require_paths = ['lib']

  spec.add_dependency 'rack',           '~> 1.6.0'
  spec.add_dependency 'http_parser.rb', '~> 0.6.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test'
end
