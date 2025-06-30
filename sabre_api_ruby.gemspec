# frozen_string_literal: true

require_relative 'lib/sabre_api_ruby/version'

Gem::Specification.new do |spec|
  spec.name = 'sabre_api_ruby'
  spec.version = SabreApiRuby::VERSION
  spec.authors = ['Jed Seculles']
  spec.email = ['jedseculles@sprint19.com']

  spec.summary = 'Ruby client for Sabre Dev Studio Booking Management APIs'
  spec.description = "A comprehensive Ruby gem for interacting with Sabre's Booking Management API endpoints including createBooking, getBooking, cancelBooking, modifyBooking, and checkFlightTickets."
  spec.homepage = 'https://github.com/Sprint19/sabre_api_ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('{lib,config}/**/*') + %w[README.md LICENSE CHANGELOG.md]
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 6.0'
  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'mutex_m', '~> 0.1'
  spec.add_dependency 'oauth2', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'dotenv', '~> 2.8'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.20'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'vcr', '~> 6.1'
  spec.add_development_dependency 'webmock', '~> 3.18'
  spec.add_development_dependency 'yard', '~> 0.9'
end
