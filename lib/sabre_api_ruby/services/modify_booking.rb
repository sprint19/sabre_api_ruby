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
        if booking_id.blank?
          raise ValidationError, "Booking ID is required"
        end
      end

      def validate_modification_params(params)
        if params.empty?
          raise ValidationError, "At least one modification parameter is required"
        end

        allowed_fields = %w[passengers flights pricing contact_info remarks ticketing]
        provided_fields = params.keys.map(&:to_s)
        invalid_fields = provided_fields - allowed_fields

        if invalid_fields.any?
          raise ValidationError, "Invalid modification fields: #{invalid_fields.join(', ')}"
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
          booking_id: response.dig("bookingId"),
          confirmation_number: response.dig("confirmationNumber"),
          status: response.dig("status"),
          passengers: response.dig("passengers"),
          flights: response.dig("flights"),
          pricing: response.dig("pricing"),
          ticketing: response.dig("ticketing"),
          contact_info: response.dig("contactInfo"),
          remarks: response.dig("remarks"),
          modified_at: response.dig("modifiedAt"),
          raw_response: response
        }
      end
    end
  end
end 