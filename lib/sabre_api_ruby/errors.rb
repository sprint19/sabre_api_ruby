# frozen_string_literal: true

module SabreApiRuby
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class APIError < Error
    attr_reader :status_code, :error_code, :response_body

    def initialize(message, status_code = nil, error_code = nil, response_body = nil)
      super(message)
      @status_code = status_code
      @error_code = error_code
      @response_body = response_body
    end
  end

  class AuthenticationError < APIError; end

  class RateLimitError < APIError; end

  class ValidationError < APIError; end

  class NotFoundError < APIError; end

  class ServerError < APIError; end
end
