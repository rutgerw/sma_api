# frozen_string_literal: true

require 'bundler/setup'
require 'byebug'
require 'vcr'
require 'sma_api'

ENV['SMA_API_HOST'] ||= '192.168.0.1'
ENV['SMA_API_WEB_PASSWORD'] ||= 'some_password'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |c|
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'spec/cassettes'
  c.filter_sensitive_data('<SMA_API_WEB_PASSWORD>') { ENV.fetch('SMA_API_WEB_PASSWORD', nil) }
  c.filter_sensitive_data('<SMA_API_HOST>') { ENV.fetch('SMA_API_HOST', nil) }
end
