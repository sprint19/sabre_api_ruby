# frozen_string_literal: true

module SabreApiRuby
  module Services
    class CheckFlightTickets
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def call(booking_id)
        validate_booking_id(booking_id)
        response = client.request(:get, "/booking/#{booking_id}/tickets")
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
          tickets: response.dig("tickets")&.map { |ticket| build_ticket_info(ticket) },
          ticket_status: response.dig("ticketStatus"),
          issued_at: response.dig("issuedAt"),
          raw_response: response
        }
      end

      def build_ticket_info(ticket)
        {
          ticket_number: ticket.dig("ticketNumber"),
          passenger_name: ticket.dig("passengerName"),
          flight_number: ticket.dig("flightNumber"),
          origin: ticket.dig("origin"),
          destination: ticket.dig("destination"),
          departure_date: ticket.dig("departureDate"),
          ticket_status: ticket.dig("ticketStatus"),
          issued_date: ticket.dig("issuedDate"),
          fare_basis: ticket.dig("fareBasis"),
          total_amount: ticket.dig("totalAmount"),
          currency: ticket.dig("currency")
        }
      end
    end
  end
end 