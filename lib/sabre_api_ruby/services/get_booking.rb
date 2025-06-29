# frozen_string_literal: true

module SabreApiRuby
  module Services
    class GetBooking
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def call(booking_id)
        validate_booking_id(booking_id)
        response = client.request(:get, "/booking/#{booking_id}")
        build_response(response)
      end

      private

      def validate_booking_id(booking_id)
        if booking_id.blank?
          raise ValidationError, "Booking ID is required"
        end
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
          contact_info: response.dig("contactInfo"),
          remarks: response.dig("remarks"),
          created_at: response.dig("createdAt"),
          updated_at: response.dig("updatedAt"),
          raw_response: response
        }
      end
    end
  end
end 