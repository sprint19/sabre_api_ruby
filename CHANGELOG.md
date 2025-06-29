# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-01-01

### Added
- Initial release of Sabre API Ruby gem
- Full support for Sabre Booking Management API endpoints:
  - `createBooking` - Create new flight bookings
  - `getBooking` - Retrieve booking details  
  - `cancelBooking` - Cancel existing bookings
  - `modifyBooking` - Modify booking details
  - `checkFlightTickets` - Check ticket status and information
- OAuth2 authentication with automatic token refresh
- Environment support (production, test, development)
- Comprehensive error handling with API-specific error classes
- Rails integration with initializer support
- Standalone usage support
- Full RSpec test coverage with WebMock and VCR
- Comprehensive documentation and usage examples 