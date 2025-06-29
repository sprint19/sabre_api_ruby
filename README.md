# Sabre API Ruby

A comprehensive Ruby gem for interacting with Sabre's Booking Management API endpoints. This gem provides full support for all Sabre Dev Studio Booking Management APIs with OAuth2 authentication, automatic token refresh, and comprehensive error handling.

## Features

- **Full API Coverage**: Support for all Sabre Booking Management endpoints
  - `createBooking` - Create new flight bookings
  - `getBooking` - Retrieve booking details
  - `cancelBooking` - Cancel existing bookings
  - `modifyBooking` - Modify booking details
  - `checkFlightTickets` - Check ticket status and information

- **OAuth2 Authentication**: Automatic token management with refresh
- **Environment Support**: Production, test, and development environments
- **Comprehensive Error Handling**: API-specific error classes and messages
- **Rails Integration**: Easy setup with Rails initializers
- **Standalone Usage**: Can be used outside of Rails applications
- **Full Test Coverage**: RSpec tests with WebMock and VCR

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sabre_api_ruby'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install sabre_api_ruby
```

## Configuration

### Rails Application

Create an initializer file `config/initializers/sabre_api_ruby.rb`:

```ruby
SabreApiRuby.configure do |config|
  # OAuth2 credentials - set these in your environment variables
  config.client_id = ENV["SABRE_CLIENT_ID"]
  config.client_secret = ENV["SABRE_CLIENT_SECRET"]
  
  # Environment setting (production, test, development)
  config.environment = Rails.env.production? ? :production : :development
  
  # Timeout settings (in seconds)
  config.timeout = ENV.fetch("SABRE_TIMEOUT", 30).to_i
  config.open_timeout = ENV.fetch("SABRE_OPEN_TIMEOUT", 10).to_i
  
  # Custom user agent (optional)
  config.user_agent = "YourApp/#{Rails.version} SabreApiRuby/#{SabreApiRuby::VERSION}"
end
```

### Standalone Usage

```ruby
require 'sabre_api_ruby'

SabreApiRuby.configure do |config|
  config.client_id = "your_client_id"
  config.client_secret = "your_client_secret"
  config.environment = :test  # or :production
  config.timeout = 30
  config.open_timeout = 10
end
```

## Usage

### Module-level Methods (Recommended)

The gem provides convenient module-level methods for all API endpoints:

```ruby
# Create a booking
booking = SabreApiRuby.create_booking(
  passengers: [
    {
      type: "ADT",
      firstName: "John",
      lastName: "Doe",
      dateOfBirth: "1990-01-01"
    }
  ],
  flights: [
    {
      origin: "LAX",
      destination: "JFK",
      departureDate: "2024-01-15",
      airline: "AA",
      flightNumber: "123"
    }
  ],
  pricing: {
    currency: "USD",
    total: 500.00
  },
  contact_info: {
    email: "john.doe@example.com",
    phone: "+1234567890"
  }
)

puts "Booking created: #{booking[:booking_id]}"
puts "Confirmation: #{booking[:confirmation_number]}"

# Get booking details
booking_details = SabreApiRuby.get_booking("BK123456")
puts "Status: #{booking_details[:status]}"

# Cancel a booking
cancellation = SabreApiRuby.cancel_booking("BK123456", 
  reason: "Customer request",
  remarks: "Cancelled due to schedule change"
)
puts "Cancelled: #{cancellation[:cancellation_number]}"

# Modify a booking
modified_booking = SabreApiRuby.modify_booking("BK123456",
  passengers: [
    {
      type: "ADT",
      firstName: "John",
      lastName: "Smith",  # Changed last name
      dateOfBirth: "1990-01-01"
    }
  ]
)
puts "Modified: #{modified_booking[:booking_id]}"

# Check flight tickets
tickets = SabreApiRuby.check_flight_tickets("BK123456")
tickets[:tickets].each do |ticket|
  puts "Ticket: #{ticket[:ticket_number]} - Status: #{ticket[:ticket_status]}"
end
```

### Client Instance Usage

For more control, you can use the client directly:

```ruby
client = SabreApiRuby.client

# Create booking
booking = client.create_booking(
  passengers: [
    {
      type: "ADT",
      firstName: "Jane",
      lastName: "Smith"
    }
  ],
  flights: [
    {
      origin: "SFO",
      destination: "ORD",
      departureDate: "2024-02-01"
    }
  ]
)

# Get booking
details = client.get_booking(booking[:booking_id])

# Cancel booking
client.cancel_booking(booking[:booking_id], reason: "Schedule conflict")
```

## API Endpoints

### Create Booking

Creates a new flight booking with passengers and flight information.

```ruby
SabreApiRuby.create_booking(
  passengers: [
    {
      type: "ADT",           # Required: ADT (Adult), CHD (Child), INF (Infant)
      firstName: "John",     # Required
      lastName: "Doe",       # Required
      dateOfBirth: "1990-01-01",
      gender: "M",
      passportNumber: "123456789"
    }
  ],
  flights: [
    {
      origin: "LAX",         # Required: Origin airport code
      destination: "JFK",    # Required: Destination airport code
      departureDate: "2024-01-15",  # Required: YYYY-MM-DD format
      airline: "AA",
      flightNumber: "123",
      cabinClass: "ECONOMY"
    }
  ],
  pricing: {
    currency: "USD",
    total: 500.00,
    base: 400.00,
    taxes: 100.00
  },
  payment: {
    method: "CREDIT_CARD",
    cardType: "VISA",
    cardNumber: "4111111111111111",
    expiryMonth: "12",
    expiryYear: "2025",
    cvv: "123"
  },
  contact_info: {
    email: "john.doe@example.com",
    phone: "+1234567890",
    address: {
      street: "123 Main St",
      city: "Los Angeles",
      state: "CA",
      zipCode: "90210",
      country: "US"
    }
  },
  remarks: "Special meal request",
  ticketing: {
    timeLimit: "2024-01-02T10:00:00Z"
  }
)
```

### Get Booking

Retrieves detailed information about an existing booking.

```ruby
booking = SabreApiRuby.get_booking("BK123456")

# Response includes:
# - booking_id
# - confirmation_number
# - status
# - passengers
# - flights
# - pricing
# - ticketing
# - contact_info
# - remarks
# - created_at
# - updated_at
```

### Cancel Booking

Cancels an existing booking with optional reason and refund information.

```ruby
cancellation = SabreApiRuby.cancel_booking("BK123456",
  reason: "Customer request",
  remarks: "Cancelled due to schedule change",
  refund_request: {
    method: "ORIGINAL_PAYMENT",
    amount: 500.00,
    currency: "USD"
  }
)

# Response includes:
# - booking_id
# - status
# - cancellation_number
# - cancelled_at
# - refund_info
# - remarks
```

### Modify Booking

Modifies an existing booking with updated information.

```ruby
modified_booking = SabreApiRuby.modify_booking("BK123456",
  passengers: [
    {
      type: "ADT",
      firstName: "John",
      lastName: "Smith",  # Updated last name
      dateOfBirth: "1990-01-01"
    }
  ],
  flights: [
    {
      origin: "LAX",
      destination: "JFK",
      departureDate: "2024-01-16",  # Updated date
      airline: "AA",
      flightNumber: "124"  # Updated flight
    }
  ],
  contact_info: {
    email: "john.smith@example.com"  # Updated email
  },
  remarks: "Updated contact information"
)
```

### Check Flight Tickets

Retrieves ticket information and status for a booking.

```ruby
tickets = SabreApiRuby.check_flight_tickets("BK123456")

# Response includes:
# - booking_id
# - tickets (array of ticket details)
# - ticket_status
# - issued_at

tickets[:tickets].each do |ticket|
  puts "Ticket Number: #{ticket[:ticket_number]}"
  puts "Passenger: #{ticket[:passenger_name]}"
  puts "Flight: #{ticket[:flight_number]}"
  puts "Status: #{ticket[:ticket_status]}"
  puts "Amount: #{ticket[:total_amount]} #{ticket[:currency]}"
end
```

## Error Handling

The gem provides specific error classes for different types of API errors:

```ruby
begin
  booking = SabreApiRuby.create_booking(invalid_params)
rescue SabreApiRuby::ValidationError => e
  puts "Validation error: #{e.message}"
rescue SabreApiRuby::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue SabreApiRuby::RateLimitError => e
  puts "Rate limited: #{e.message}"
rescue SabreApiRuby::NotFoundError => e
  puts "Booking not found: #{e.message}"
rescue SabreApiRuby::ServerError => e
  puts "Server error: #{e.message}"
rescue SabreApiRuby::APIError => e
  puts "API error: #{e.message}"
end
```

## Testing

The gem includes comprehensive RSpec tests. To run the test suite:

```bash
bundle exec rspec
```

Tests use WebMock and VCR for HTTP request stubbing and recording.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Sprint19/sabre_api_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SabreApiRuby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
