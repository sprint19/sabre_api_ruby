# frozen_string_literal: true

module SabreApiRuby
  class Configuration
    attr_accessor :client_id, :client_secret, :environment, :timeout, :open_timeout,
                  :oauth_token_url, :api_base_url, :user_agent

    def initialize
      @environment = :production
      @timeout = 30
      @open_timeout = 10
      @user_agent = "SabreApiRuby/#{SabreApiRuby::VERSION}"
      set_urls
    end

    def production?
      environment.to_sym == :production
    end

    def test?
      environment.to_sym == :test
    end

    def development?
      environment.to_sym == :development
    end

    def oauth_token_url
      @oauth_token_url ||= production? ? "https://api.sabre.com/v2/auth/token" : "https://api.test.sabre.com/v2/auth/token"
    end

    def api_base_url
      @api_base_url ||= production? ? "https://api.sabre.com/v4" : "https://api.test.sabre.com/v4"
    end

    def validate!
      raise ConfigurationError, "client_id is required" if client_id.blank?
      raise ConfigurationError, "client_secret is required" if client_secret.blank?
      raise ConfigurationError, "Invalid environment: #{environment}" unless %i[production test development].include?(environment.to_sym)
    end

    private

    def set_urls
      case environment.to_sym
      when :production
        @oauth_token_url = "https://api.sabre.com/v2/auth/token"
        @api_base_url = "https://api.sabre.com/v4"
      when :test, :development
        @oauth_token_url = "https://api.test.sabre.com/v2/auth/token"
        @api_base_url = "https://api.test.sabre.com/v4"
      end
    end
  end
end 