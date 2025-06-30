# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'sabre_api_ruby'
require 'webmock/rspec'
require 'vcr'

# Configure WebMock to allow localhost connections for development
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['codeclimate.com'] # Allow code coverage if used
)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Don't allow HTTP connections when no cassette is in use
  config.allow_http_connections_when_no_cassette = false

  # Filter out sensitive data
  config.filter_sensitive_data('<SABRE_CLIENT_ID>') { ENV.fetch('SABRE_CLIENT_ID', nil) }
  config.filter_sensitive_data('<SABRE_CLIENT_SECRET>') { ENV.fetch('SABRE_CLIENT_SECRET', nil) }
  config.filter_sensitive_data('<ACCESS_TOKEN>') { 'test_access_token' }

  # Record new interactions
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method uri body]
  }

  # Ignore requests that are handled by WebMock
  config.ignore_request do |_request|
    # Ignore all requests for client tests since we're using WebMock
    true
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  # Clean up WebMock stubs after each test
  config.after(:each) do
    WebMock.reset!
  end

  # Disable VCR for client tests that use WebMock
  config.around(:each, :vcr) do |example|
    VCR.use_cassette(example.metadata[:vcr]) do
      example.run
    end
  end
end
