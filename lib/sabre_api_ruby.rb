# frozen_string_literal: true

require "faraday"
require "oauth2"
require "active_support"
require "active_support/core_ext"
require "json"

require_relative "sabre_api_ruby/version"
require_relative "sabre_api_ruby/client"
require_relative "sabre_api_ruby/configuration"
require_relative "sabre_api_ruby/errors"
require_relative "sabre_api_ruby/services/create_booking"
require_relative "sabre_api_ruby/services/get_booking"
require_relative "sabre_api_ruby/services/cancel_booking"
require_relative "sabre_api_ruby/services/modify_booking"
require_relative "sabre_api_ruby/services/check_flight_tickets"

module SabreApiRuby
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      @client ||= Client.new(configuration)
    end

    def create_booking(params = {})
      client.create_booking(params)
    end

    def get_booking(booking_id)
      client.get_booking(booking_id)
    end

    def cancel_booking(booking_id, params = {})
      client.cancel_booking(booking_id, params)
    end

    def modify_booking(booking_id, params = {})
      client.modify_booking(booking_id, params)
    end

    def check_flight_tickets(booking_id)
      client.check_flight_tickets(booking_id)
    end
  end
end 