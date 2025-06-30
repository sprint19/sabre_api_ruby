# frozen_string_literal: true

require "dotenv/load" if File.exist?(".env")

SabreApiRuby.configure do |config|
  # OAuth2 credentials - set these in your environment variables
  config.client_id = ENV["SABRE_CLIENT_ID"]
  config.client_secret = ENV["SABRE_CLIENT_SECRET"]
  
  # Environment setting (production, test, development)
  config.environment = ENV.fetch("SABRE_ENVIRONMENT", "test").to_sym
  
  # Timeout settings (in seconds)
  config.timeout = ENV.fetch("SABRE_TIMEOUT", 30).to_i
  config.open_timeout = ENV.fetch("SABRE_OPEN_TIMEOUT", 10).to_i
  
  # Custom user agent (optional)
  config.user_agent = "YourApp/#{Rails.version} SabreApiRuby/#{SabreApiRuby::VERSION}" if defined?(Rails)
end 