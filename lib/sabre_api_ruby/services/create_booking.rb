# frozen_string_literal: true

module SabreApiRuby
  module Services
    class CreateBooking
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def call(params = {})
        validate_params(params)
        response = client.request(:post, "/booking/create", build_request_body(params))
        build_response(response)
      end

      private

      def validate_params(params)
        required_fields = %w[passengers flights]
        missing_fields = required_fields - params.keys.map(&:to_s)
        
        if missing_fields.any?
          raise ValidationError, "Missing required fields: #{missing_fields.join(', ')}"
        end

        validate_passengers(params[:passengers])
        validate_flights(params[:flights])
      end

      def validate_passengers(passengers)
        return unless passengers

        passengers.each_with_index do |passenger, index|
          required_fields = %w[type firstName lastName]
          missing_fields = required_fields - passenger.keys.map(&:to_s)
          
          if missing_fields.any?
            raise ValidationError, "Passenger #{index + 1} missing required fields: #{missing_fields.join(', ')}"
          end
        end
      end

      def validate_flights(flights)
        return unless flights

        flights.each_with_index do |flight, index|
          required_fields = %w[origin destination departureDate]
          missing_fields = required_fields - flight.keys.map(&:to_s)
          
          if missing_fields.any?
            raise ValidationError, "Flight #{index + 1} missing required fields: #{missing_fields.join(', ')}"
          end
        end
      end

      def build_request_body(params)
        {
          passengers: params[:passengers],
          flights: params[:flights],
          pricing: params[:pricing],
          payment: params[:payment],
          contactInfo: params[:contact_info],
          remarks: params[:remarks],
          ticketing: params[:ticketing]
        }.compact
      end

      def build_response(response)
        {
          booking_id: response.dig("bookingId"),
          confirmation_number: response.dig("confirmationNumber"),
          status: response.dig("status"),
          passengers: response.dig("passengers"),
          flights: response.dig("flights"),
          pricing: response.dig("pricing"),
          ticketing: response.dig("ticketing"),
          created_at: response.dig("createdAt"),
          raw_response: response
        }
      end
    end
  end
end 