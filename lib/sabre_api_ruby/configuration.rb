# frozen_string_literal: true

module SabreApiRuby
  class Configuration
    attr_accessor :client_id, :client_secret, :environment, :timeout, :open_timeout,
                  :oauth_token_url, :api_base_url, :user_agent

    def initialize
      @environment = :development
      @timeout = 30
      @open_timeout = 10
      @user_agent = "SabreApiRuby/#{SabreApiRuby::VERSION}"
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
      @oauth_token_url ||= production? ? 'https://api.sabre.com/v2/auth/token' : 'https://api.test.sabre.com/v2/auth/token'
    end

    def api_base_url
      @api_base_url ||= production? ? 'https://api.sabre.com/v4' : 'https://api.test.sabre.com/v4'
    end

    def validate!
      raise ConfigurationError, 'Client ID is required' if client_id.blank?
      raise ConfigurationError, 'Client Secret is required' if client_secret.blank?
      raise ConfigurationError, "Invalid environment: #{environment}" unless %i[production test
                                                                                development].include?(environment.to_sym)
    end

    # Force URL regeneration when environment changes
    def environment=(env)
      env_sym = env.to_sym
      unless %i[production test development].include?(env_sym)
        raise ArgumentError, 'Environment must be one of: development, test, production'
      end

      @environment = env_sym
      @oauth_token_url = nil
      @api_base_url = nil
    end

    def timeout=(value)
      unless value.is_a?(Integer) && value > 0
        raise ArgumentError, 'Timeout must be a positive integer'
      end

      @timeout = value
    end

    def open_timeout=(value)
      unless value.is_a?(Integer) && value > 0
        raise ArgumentError, 'Open timeout must be a positive integer'
      end

      @open_timeout = value
    end

    private

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end
  end
end
