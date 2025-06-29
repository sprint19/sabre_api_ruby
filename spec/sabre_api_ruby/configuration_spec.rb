# frozen_string_literal: true

require "spec_helper"

RSpec.describe SabreApiRuby::Configuration do
  let(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.environment).to eq(:production)
      expect(config.timeout).to eq(30)
      expect(config.open_timeout).to eq(10)
      expect(config.user_agent).to include("SabreApiRuby")
    end
  end

  describe "environment methods" do
    it "returns correct environment status" do
      config.environment = :production
      expect(config.production?).to be true
      expect(config.test?).to be false
      expect(config.development?).to be false

      config.environment = :test
      expect(config.production?).to be false
      expect(config.test?).to be true
      expect(config.development?).to be false

      config.environment = :development
      expect(config.production?).to be false
      expect(config.test?).to be false
      expect(config.development?).to be true
    end
  end

  describe "#oauth_token_url" do
    it "returns production URL for production environment" do
      config.environment = :production
      expect(config.oauth_token_url).to eq("https://api.sabre.com/v2/auth/token")
    end

    it "returns test URL for test environment" do
      config.environment = :test
      expect(config.oauth_token_url).to eq("https://api.test.sabre.com/v2/auth/token")
    end

    it "returns test URL for development environment" do
      config.environment = :development
      expect(config.oauth_token_url).to eq("https://api.test.sabre.com/v2/auth/token")
    end
  end

  describe "#api_base_url" do
    it "returns production URL for production environment" do
      config.environment = :production
      expect(config.api_base_url).to eq("https://api.sabre.com/v4")
    end

    it "returns test URL for test environment" do
      config.environment = :test
      expect(config.api_base_url).to eq("https://api.test.sabre.com/v4")
    end

    it "returns test URL for development environment" do
      config.environment = :development
      expect(config.api_base_url).to eq("https://api.test.sabre.com/v4")
    end
  end

  describe "#validate!" do
    it "raises error when client_id is missing" do
      config.client_secret = "secret"
      expect { config.validate! }.to raise_error(SabreApiRuby::ConfigurationError, "client_id is required")
    end

    it "raises error when client_secret is missing" do
      config.client_id = "id"
      expect { config.validate! }.to raise_error(SabreApiRuby::ConfigurationError, "client_secret is required")
    end

    it "raises error for invalid environment" do
      config.client_id = "id"
      config.client_secret = "secret"
      config.environment = :invalid
      expect { config.validate! }.to raise_error(SabreApiRuby::ConfigurationError, "Invalid environment: invalid")
    end

    it "does not raise error with valid configuration" do
      config.client_id = "id"
      config.client_secret = "secret"
      config.environment = :production
      expect { config.validate! }.not_to raise_error
    end
  end
end 