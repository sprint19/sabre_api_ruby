# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Gemfile with development and test dependencies
- CONTRIBUTING.md with comprehensive contribution guidelines
- ISSUE_TEMPLATE.md for structured bug reports and feature requests
- PULL_REQUEST_TEMPLATE.md for standardized PR submissions
- CODE_OF_CONDUCT.md following Contributor Covenant v2.0
- Development scripts (bin/console, bin/setup)
- Rakefile with build and test tasks
- RuboCop configuration for code style enforcement
- Comprehensive RSpec test suite with WebMock and VCR
- Rails initializer for easy configuration

### Changed
- Updated gemspec with proper metadata and dependencies
- Enhanced README.md with comprehensive documentation and examples

## [0.1.0] - 2025-06-29

### Added
- Initial release of Sabre API Ruby gem
- Full support for Sabre Booking Management API endpoints:
  - `createBooking` - Create new flight bookings with comprehensive parameter validation
  - `getBooking` - Retrieve detailed booking information
  - `cancelBooking` - Cancel bookings with reason and refund support
  - `modifyBooking` - Update booking details with validation
  - `checkFlightTickets` - Check ticket status and information
- OAuth2 authentication with automatic token refresh
- Environment support (production, test, development)
- Comprehensive error handling with API-specific error classes:
  - `SabreApiRuby::ValidationError`
  - `SabreApiRuby::AuthenticationError`
  - `SabreApiRuby::RateLimitError`
  - `SabreApiRuby::NotFoundError`
  - `SabreApiRuby::ServerError`
- Rails integration with initializer support
- Standalone usage support with direct client instantiation
- Module-level convenience methods for all endpoints
- Configuration management with validation
- HTTP client with Faraday and middleware support
- Service classes for each API endpoint with parameter validation
- Response wrappers with structured data
- Comprehensive documentation with usage examples
- MIT license for open source use

### Technical Details
- Ruby 2.7+ compatibility
- Faraday HTTP client with JSON middleware
- OAuth2 gem for authentication
- ActiveSupport for Rails integration
- WebMock and VCR for testing
- RuboCop for code style enforcement
- RSpec for comprehensive testing
- YARD for documentation generation
- SimpleCov for test coverage reporting

## [v1.0] - 2024-06-07
### Added
- Full support for Sabre Booking Management API endpoints:
  - `createBooking`, `getBooking`, `cancelBooking`, `modifyBooking`, `checkFlightTickets`
- OAuth2 authentication with automatic token refresh
- Comprehensive error handling with custom error classes
- Rails integration via initializer and standalone configuration support
- RSpec test suite with WebMock and VCR for HTTP stubbing and recording
- Environment variable support via dotenv
- Example usage and documentation in README

### Changed
- **Breaking:** Removed `faraday_middleware` dependency (now only requires `faraday`)
- Lowered minimum Ruby version to 2.6.0
- Improved configuration validation and error messages
- Improved test reliability and coverage

### Fixed
- WebMock and VCR configuration for reliable test isolation
- Token refresh and OAuth2 mocking in tests
- Error class inheritance and constructor signatures
- Parameter validation in service classes

## [0.1.0] - 2025-06-29

### Added
- Initial release of Sabre API Ruby gem
- Full support for Sabre Booking Management API endpoints:
  - `createBooking` - Create new flight bookings with comprehensive parameter validation
  - `getBooking` - Retrieve detailed booking information
  - `cancelBooking` - Cancel bookings with reason and refund support
  - `modifyBooking` - Update booking details with validation
  - `checkFlightTickets` - Check ticket status and information
- OAuth2 authentication with automatic token refresh
- Environment support (production, test, development)
- Comprehensive error handling with API-specific error classes:
  - `SabreApiRuby::ValidationError`
  - `SabreApiRuby::AuthenticationError`
  - `SabreApiRuby::RateLimitError`
  - `SabreApiRuby::NotFoundError`
  - `SabreApiRuby::ServerError`
- Rails integration with initializer support
- Standalone usage support with direct client instantiation
- Module-level convenience methods for all endpoints
- Configuration management with validation
- HTTP client with Faraday and middleware support
- Service classes for each API endpoint with parameter validation
- Response wrappers with structured data
- Comprehensive documentation with usage examples
- MIT license for open source use

### Technical Details
- Ruby 2.7+ compatibility
- Faraday HTTP client with JSON middleware
- OAuth2 gem for authentication
- ActiveSupport for Rails integration
- WebMock and VCR for testing
- RuboCop for code style enforcement
- RSpec for comprehensive testing
- YARD for documentation generation
- SimpleCov for test coverage reporting 