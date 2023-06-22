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

  spec.metadata      = {
    'changelog_uri' => 'https://github.com/rutgerw/sma_api/blob/master/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  spec.required_ruby_version = '>= 3.1'
  spec.require_paths = ['lib']
  spec.files = Dir.glob('{lib}/**/*') + %w[README.md License.txt]

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'byebug', '~> 11.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.40'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.16'
  spec.add_development_dependency 'vcr', '~> 6.1'
  spec.add_development_dependency 'webmock', '~> 3.18'
end
