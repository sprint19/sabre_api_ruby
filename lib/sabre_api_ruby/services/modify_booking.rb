# frozen_string_literal: true

module SabreApiRuby
  module Services
    class ModifyBooking
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def call(booking_id, params = {})
        validate_booking_id(booking_id)
        validate_modification_params(params)
        response = client.request(:put, "/booking/#{booking_id}", build_request_body(params))
        build_response(response)
      end

      private

      def validate_booking_id(booking_id)
        return unless booking_id.blank?

        raise ValidationError, 'Booking ID is required'
      end

      def validate_modification_params(params)
        unless params.is_a?(Hash)
          raise ValidationError, 'Parameters must be a hash'
        end

        if params.empty?
          raise ValidationError, 'At least one modification parameter is required'
        end

        allowed_fields = %w[passengers flights pricing contact_info remarks ticketing]
        provided_fields = params.keys.map(&:to_s)
        invalid_fields = provided_fields - allowed_fields

        if invalid_fields.any?
          raise ValidationError, "Invalid modification fields: #{invalid_fields.join(', ')}"
        end

        # Validate passengers if provided
        if params[:passengers]
          validate_passengers(params[:passengers])
        end

        # Validate flights if provided
        return unless params[:flights]

        validate_flights(params[:flights])
      end

      def validate_passengers(passengers)
        return unless passengers.is_a?(Array)

        passengers.each_with_index do |passenger, index|
          next unless passenger.is_a?(Hash)

          required_fields = %w[type lastName]
          missing_fields = required_fields - passenger.keys.map(&:to_s)

          if missing_fields.any?
            raise ValidationError, "Passenger #{index + 1} missing required fields: #{missing_fields.join(', ')}"
          end
        end
      end

      def validate_flights(flights)
        return unless flights.is_a?(Array)

        flights.each_with_index do |flight, index|
          next unless flight.is_a?(Hash)

          required_fields = %w[destination departureDate]
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
          contactInfo: params[:contact_info],
          remarks: params[:remarks],
          ticketing: params[:ticketing]
        }.compact
      end

      def build_response(response)
        {
          booking_id: response.dig('bookingId'),
          confirmation_number: response.dig('confirmationNumber'),
          status: response.dig('status'),
          passengers: response.dig('passengers'),
          flights: response.dig('flights'),
          pricing: response.dig('pricing'),
          ticketing: response.dig('ticketing'),
          contact_info: response.dig('contactInfo'),
          remarks: response.dig('remarks'),
          modified_at: response.dig('modifiedAt'),
          raw_response: response
        }
      end
    end
  end
end
