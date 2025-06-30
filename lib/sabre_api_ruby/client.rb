# frozen_string_literal: true

module SabreApiRuby
  class Client
    attr_reader :configuration, :oauth_client, :access_token

    def initialize(configuration)
      @configuration = configuration
      configuration.validate!
      setup_oauth_client
    end

    def create_booking(params = {})
      Services::CreateBooking.new(self).call(params)
    end

    def get_booking(booking_id)
      Services::GetBooking.new(self).call(booking_id)
    end

    def cancel_booking(booking_id, params = {})
      Services::CancelBooking.new(self).call(booking_id, params)
    end

    def modify_booking(booking_id, params = {})
      Services::ModifyBooking.new(self).call(booking_id, params)
    end

    def check_flight_tickets(booking_id)
      Services::CheckFlightTickets.new(self).call(booking_id)
    end

    def get_access_token
      return @access_token if @access_token && !@access_token.expired?

      @access_token = @oauth_client.client_credentials.get_token
      @access_token
    rescue OAuth2::Error => e
      raise AuthenticationError, "Failed to obtain access token: #{e.message}"
    end

    def request(method, endpoint, params = {})
      token = get_access_token

      response = connection.send(method) do |req|
        req.url endpoint
        req.headers['Authorization'] = "Bearer #{token.token}"
        req.headers['Content-Type'] = 'application/json'
        req.headers['User-Agent'] = configuration.user_agent

        case method
        when :get
          req.params.update(params)
        when :post, :put, :patch
          req.body = params.to_json
        end
      end

      handle_response(response)
    rescue Faraday::TimeoutError
      raise APIError, 'Request timeout'
    rescue Faraday::ConnectionFailed
      raise APIError, 'Connection failed'
    end

    private

    def setup_oauth_client
      @oauth_client = OAuth2::Client.new(
        configuration.client_id,
        configuration.client_secret,
        site: configuration.oauth_token_url,
        token_url: '/',
        auth_scheme: :request_body
      )
    end

    def connection
      @connection ||= Faraday.new(url: configuration.api_base_url) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
        faraday.options.timeout = configuration.timeout
        faraday.options.open_timeout = configuration.open_timeout
      end
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 400
        raise ValidationError.new('Bad Request', response.status, extract_error_code(response), response.body)
      when 401
        raise AuthenticationError.new('Unauthorized', response.status, extract_error_code(response), response.body)
      when 404
        raise NotFoundError.new('Not Found', response.status, extract_error_code(response), response.body)
      when 429
        raise RateLimitError.new('Rate Limited', response.status, extract_error_code(response), response.body)
      when 500..599
        raise ServerError.new('Server Error', response.status, extract_error_code(response), response.body)
      else
        raise APIError.new('Unexpected response', response.status, extract_error_code(response), response.body)
      end
    end

    def extract_error_code(response)
      return nil unless response.body.is_a?(Hash)

      response.body.dig('errors', 0, 'code') ||
        response.body.dig('error', 'code') ||
        response.body['code']
    end
  end
end
