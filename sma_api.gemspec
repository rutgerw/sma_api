# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sma_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'sma_api'
  spec.version       = SmaApi::VERSION
  spec.authors       = ['Rutger Wessels']
  spec.email         = ['rutger@rutgerwessels.nl']

  spec.summary       = 'Extract data from a SMA Inverter web interface.'
  spec.description   = 'Extract data from a SMA Inverter web interface.'
  spec.homepage      = 'https://github.com/rutgerw/sma_api'
  spec.license       = 'MIT'

  spec.require_paths = ['lib']
  spec.files = Dir.glob('{lib}/**/*') + %w[README.md License.txt]

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'byebug', '~> 11.1', '>= 11.1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.82.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.39'
  spec.add_development_dependency 'vcr', '~> 5.1'
  spec.add_development_dependency 'webmock', '~> 3.8', '>= 3.8.3'
  spec.add_development_dependency 'fakefs', '~> 1.2', '>= 1.2.2'
end
