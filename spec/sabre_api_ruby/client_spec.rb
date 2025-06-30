# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SabreApiRuby::Client do
  # Disable VCR for client tests since we're using WebMock
  before(:all) do
    VCR.turn_off!
  end

  after(:all) do
    VCR.turn_on!
  end

  let(:configuration) do
    SabreApiRuby::Configuration.new.tap do |config|
      config.client_id = 'test_client_id'
      config.client_secret = 'test_client_secret'
      config.environment = :test
    end
  end

  let(:client) { described_class.new(configuration) }

  describe '#initialize' do
    it 'creates a client with valid configuration' do
      expect(client.configuration).to eq(configuration)
    end

    it 'raises error with invalid configuration' do
      invalid_config = SabreApiRuby::Configuration.new
      expect { described_class.new(invalid_config) }.to raise_error(SabreApiRuby::ConfigurationError)
    end
  end

  describe '#get_access_token' do
    let(:mock_token) { instance_double(OAuth2::AccessToken, token: 'test_access_token', expired?: false) }
    let(:mock_oauth_client) { instance_double(OAuth2::Client) }
    let(:mock_client_credentials) { instance_double(OAuth2::Strategy::ClientCredentials) }

    before do
      allow(OAuth2::Client).to receive(:new).and_return(mock_oauth_client)
      allow(mock_oauth_client).to receive(:client_credentials).and_return(mock_client_credentials)
      allow(mock_client_credentials).to receive(:get_token).and_return(mock_token)

      # Re-initialize the client to use the mocked OAuth2 client
      client.instance_variable_set(:@oauth_client, mock_oauth_client)
    end

    it 'obtains a new access token' do
      token = client.get_access_token
      expect(token).to eq(mock_token)
      expect(token.token).to eq('test_access_token')
    end

    it 'reuses existing token if not expired' do
      token1 = client.get_access_token
      token2 = client.get_access_token
      expect(token1).to eq(token2)
      expect(mock_client_credentials).to have_received(:get_token).once
    end

    it 'refreshes token when expired' do
      expired_token = instance_double(OAuth2::AccessToken, token: 'old_token', expired?: true)
      new_token = instance_double(OAuth2::AccessToken, token: 'new_token', expired?: false)

      # Clear any existing token
      client.instance_variable_set(:@access_token, nil)

      # Reset the mock to return different tokens
      allow(mock_client_credentials).to receive(:get_token).and_return(expired_token, new_token)

      # Set the expired token as the current token
      client.instance_variable_set(:@access_token, expired_token)

      # Get a new token (should trigger refresh)
      token = client.get_access_token
      expect(token.token).to eq('new_token')
      expect(mock_client_credentials).to have_received(:get_token).once
    end
  end

  describe '#request' do
    let(:access_token) { instance_double(OAuth2::AccessToken, token: 'test_token', expired?: false) }

    before do
      allow(client).to receive(:get_access_token).and_return(access_token)
    end

    context 'with successful response' do
      it 'makes a GET request' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .with(
            headers: {
              'Authorization' => 'Bearer test_token'
            }
          )
          .to_return(
            status: 200,
            body: '{"success": true}',
            headers: { 'Content-Type' => 'application/json' }
          )

        response = client.request(:get, '/test')
        expect(response).to eq({ 'success' => true })
      end

      it 'makes a POST request with body' do
        stub_request(:post, 'https://api.test.sabre.com/test')
          .with(
            headers: {
              'Authorization' => 'Bearer test_token'
            },
            body: { test: 'data' }.to_json
          )
          .to_return(
            status: 200,
            body: '{"success": true}',
            headers: { 'Content-Type' => 'application/json' }
          )

        response = client.request(:post, '/test', { test: 'data' })
        expect(response).to eq({ 'success' => true })
      end

      it 'handles query parameters for GET requests' do
        stub_request(:get, 'https://api.test.sabre.com/test?param1=value1&param2=value2')
          .with(
            headers: {
              'Authorization' => 'Bearer test_token'
            }
          )
          .to_return(
            status: 200,
            body: '{"success": true}',
            headers: { 'Content-Type' => 'application/json' }
          )

        response = client.request(:get, '/test', { param1: 'value1', param2: 'value2' })
        expect(response).to eq({ 'success' => true })
      end
    end

    context 'with error responses' do
      it 'raises ValidationError for 400' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_return(
            status: 400,
            body: '{"errors": [{"code": "INVALID_REQUEST"}]}',
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::ValidationError)
      end

      it 'raises AuthenticationError for 401' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_return(
            status: 401,
            body: '{"error": {"code": "UNAUTHORIZED"}}',
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::AuthenticationError)
      end

      it 'raises NotFoundError for 404' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_return(
            status: 404,
            body: '{"error": {"code": "NOT_FOUND"}}',
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::NotFoundError)
      end

      it 'raises RateLimitError for 429' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_return(
            status: 429,
            body: '{"error": {"code": "RATE_LIMITED"}}',
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::RateLimitError)
      end

      it 'raises ServerError for 500' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_return(
            status: 500,
            body: '{"error": {"code": "INTERNAL_ERROR"}}',
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::ServerError)
      end

      it 'raises APIError for unexpected status codes' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_return(
            status: 418,
            body: '{"error": {"code": "TEAPOT"}}',
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::APIError)
      end
    end

    context 'with connection errors' do
      it 'raises APIError on timeout' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_timeout

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::APIError, /Connection failed/)
      end

      it 'raises APIError on connection failure' do
        stub_request(:get, 'https://api.test.sabre.com/test')
          .to_raise(Faraday::ConnectionFailed.new('Connection failed'))

        expect { client.request(:get, '/test') }.to raise_error(SabreApiRuby::APIError, /Connection failed/)
      end
    end
  end

  describe 'API endpoint methods' do
    let(:access_token) { instance_double(OAuth2::AccessToken, token: 'test_token', expired?: false) }

    before do
      allow(client).to receive(:get_access_token).and_return(access_token)
    end

    it 'delegates create_booking to CreateBooking service' do
      service = instance_double(SabreApiRuby::Services::CreateBooking)
      allow(SabreApiRuby::Services::CreateBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with({ test: 'data' }).and_return({ success: true })

      result = client.create_booking({ test: 'data' })
      expect(result).to eq({ success: true })
    end

    it 'delegates get_booking to GetBooking service' do
      service = instance_double(SabreApiRuby::Services::GetBooking)
      allow(SabreApiRuby::Services::GetBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with('booking123').and_return({ booking_id: 'booking123' })

      result = client.get_booking('booking123')
      expect(result).to eq({ booking_id: 'booking123' })
    end

    it 'delegates cancel_booking to CancelBooking service' do
      service = instance_double(SabreApiRuby::Services::CancelBooking)
      allow(SabreApiRuby::Services::CancelBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with('booking123', { reason: 'cancelled' }).and_return({ status: 'cancelled' })

      result = client.cancel_booking('booking123', { reason: 'cancelled' })
      expect(result).to eq({ status: 'cancelled' })
    end

    it 'delegates modify_booking to ModifyBooking service' do
      service = instance_double(SabreApiRuby::Services::ModifyBooking)
      allow(SabreApiRuby::Services::ModifyBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with('booking123', { passengers: [] }).and_return({ status: 'modified' })

      result = client.modify_booking('booking123', { passengers: [] })
      expect(result).to eq({ status: 'modified' })
    end

    it 'delegates check_flight_tickets to CheckFlightTickets service' do
      service = instance_double(SabreApiRuby::Services::CheckFlightTickets)
      allow(SabreApiRuby::Services::CheckFlightTickets).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with('booking123').and_return({ tickets: [] })

      result = client.check_flight_tickets('booking123')
      expect(result).to eq({ tickets: [] })
    end
  end
end
