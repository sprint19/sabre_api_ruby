# frozen_string_literal: true

require "spec_helper"

RSpec.describe SabreApiRuby::Client do
  let(:configuration) do
    SabreApiRuby::Configuration.new.tap do |config|
      config.client_id = "test_client_id"
      config.client_secret = "test_client_secret"
      config.environment = :test
    end
  end

  let(:client) { described_class.new(configuration) }

  describe "#initialize" do
    it "creates a client with valid configuration" do
      expect(client.configuration).to eq(configuration)
    end

    it "raises error with invalid configuration" do
      invalid_config = SabreApiRuby::Configuration.new
      expect { described_class.new(invalid_config) }.to raise_error(SabreApiRuby::ConfigurationError)
    end
  end

  describe "#get_access_token" do
    it "obtains a new access token" do
      VCR.use_cassette("oauth_token") do
        token = client.get_access_token
        expect(token).to be_a(OAuth2::AccessToken)
        expect(token.token).to be_present
      end
    end

    it "reuses existing token if not expired" do
      VCR.use_cassette("oauth_token") do
        token1 = client.get_access_token
        token2 = client.get_access_token
        expect(token1).to eq(token2)
      end
    end
  end

  describe "#request" do
    let(:access_token) { instance_double(OAuth2::AccessToken, token: "test_token", expired?: false) }

    before do
      allow(client).to receive(:get_access_token).and_return(access_token)
    end

    context "with successful response" do
      it "makes a GET request" do
        stub_request(:get, "https://api.test.sabre.com/v4/test")
          .with(headers: { "Authorization" => "Bearer test_token" })
          .to_return(status: 200, body: '{"success": true}')

        response = client.request(:get, "/test")
        expect(response).to eq({ "success" => true })
      end

      it "makes a POST request with body" do
        stub_request(:post, "https://api.test.sabre.com/v4/test")
          .with(
            headers: { "Authorization" => "Bearer test_token", "Content-Type" => "application/json" },
            body: { test: "data" }.to_json
          )
          .to_return(status: 200, body: '{"success": true}')

        response = client.request(:post, "/test", { test: "data" })
        expect(response).to eq({ "success" => true })
      end
    end

    context "with error responses" do
      it "raises ValidationError for 400" do
        stub_request(:get, "https://api.test.sabre.com/v4/test")
          .to_return(status: 400, body: '{"error": {"code": "INVALID_REQUEST"}}')

        expect { client.request(:get, "/test") }.to raise_error(SabreApiRuby::ValidationError)
      end

      it "raises AuthenticationError for 401" do
        stub_request(:get, "https://api.test.sabre.com/v4/test")
          .to_return(status: 401, body: '{"error": {"code": "UNAUTHORIZED"}}')

        expect { client.request(:get, "/test") }.to raise_error(SabreApiRuby::AuthenticationError)
      end

      it "raises NotFoundError for 404" do
        stub_request(:get, "https://api.test.sabre.com/v4/test")
          .to_return(status: 404, body: '{"error": {"code": "NOT_FOUND"}}')

        expect { client.request(:get, "/test") }.to raise_error(SabreApiRuby::NotFoundError)
      end

      it "raises RateLimitError for 429" do
        stub_request(:get, "https://api.test.sabre.com/v4/test")
          .to_return(status: 429, body: '{"error": {"code": "RATE_LIMITED"}}')

        expect { client.request(:get, "/test") }.to raise_error(SabreApiRuby::RateLimitError)
      end

      it "raises ServerError for 500" do
        stub_request(:get, "https://api.test.sabre.com/v4/test")
          .to_return(status: 500, body: '{"error": {"code": "INTERNAL_ERROR"}}')

        expect { client.request(:get, "/test") }.to raise_error(SabreApiRuby::ServerError)
      end
    end
  end

  describe "API endpoint methods" do
    before do
      allow(client).to receive(:get_access_token).and_return(access_token)
    end

    it "delegates create_booking to CreateBooking service" do
      service = instance_double(SabreApiRuby::Services::CreateBooking)
      allow(SabreApiRuby::Services::CreateBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with({ test: "data" }).and_return({ success: true })

      result = client.create_booking({ test: "data" })
      expect(result).to eq({ success: true })
    end

    it "delegates get_booking to GetBooking service" do
      service = instance_double(SabreApiRuby::Services::GetBooking)
      allow(SabreApiRuby::Services::GetBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with("booking123").and_return({ booking_id: "booking123" })

      result = client.get_booking("booking123")
      expect(result).to eq({ booking_id: "booking123" })
    end

    it "delegates cancel_booking to CancelBooking service" do
      service = instance_double(SabreApiRuby::Services::CancelBooking)
      allow(SabreApiRuby::Services::CancelBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with("booking123", { reason: "cancelled" }).and_return({ status: "cancelled" })

      result = client.cancel_booking("booking123", { reason: "cancelled" })
      expect(result).to eq({ status: "cancelled" })
    end

    it "delegates modify_booking to ModifyBooking service" do
      service = instance_double(SabreApiRuby::Services::ModifyBooking)
      allow(SabreApiRuby::Services::ModifyBooking).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with("booking123", { passengers: [] }).and_return({ status: "modified" })

      result = client.modify_booking("booking123", { passengers: [] })
      expect(result).to eq({ status: "modified" })
    end

    it "delegates check_flight_tickets to CheckFlightTickets service" do
      service = instance_double(SabreApiRuby::Services::CheckFlightTickets)
      allow(SabreApiRuby::Services::CheckFlightTickets).to receive(:new).with(client).and_return(service)
      allow(service).to receive(:call).with("booking123").and_return({ tickets: [] })

      result = client.check_flight_tickets("booking123")
      expect(result).to eq({ tickets: [] })
    end
  end
end 