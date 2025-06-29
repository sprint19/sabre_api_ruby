# frozen_string_literal: true

module SabreApiRuby
  module Services
    class CancelBooking
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def call(booking_id, params = {})
        validate_booking_id(booking_id)
        response = client.request(:post, "/booking/#{booking_id}/cancel", build_request_body(params))
        build_response(response)
      end

      private

      def validate_booking_id(booking_id)
        if booking_id.blank?
          raise ValidationError, "Booking ID is required"
        end
      end

      def build_request_body(params)
        {
          reason: params[:reason],
          remarks: params[:remarks],
          refundRequest: params[:refund_request]
        }.compact
      end

      def build_response(response)
        {
          booking_id: response.dig("bookingId"),
          status: response.dig("status"),
          cancellation_number: response.dig("cancellationNumber"),
          cancelled_at: response.dig("cancelledAt"),
          refund_info: response.dig("refundInfo"),
          remarks: response.dig("remarks"),
          raw_response: response
        }
      end
    end
  end
end 