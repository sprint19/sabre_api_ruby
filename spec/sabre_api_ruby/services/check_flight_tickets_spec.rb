# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SabreApiRuby::Services::CheckFlightTickets do
  let(:client) { instance_double(SabreApiRuby::Client) }
  let(:service) { described_class.new(client) }

  describe '#call' do
    let(:booking_id) { 'BK123456' }
    let(:success_response) do
      {
        'bookingId' => 'BK123456',
        'tickets' => [
          {
            'ticketNumber' => '1234567890123',
            'passengerName' => 'JOHN DOE',
            'flightNumber' => 'AA123',
            'ticketStatus' => 'ISSUED',
            'totalAmount' => 250.00,
            'currency' => 'USD',
            'issuedAt' => '2024-01-01T10:00:00Z'
          },
          {
            'ticketNumber' => '1234567890124',
            'passengerName' => 'JANE DOE',
            'flightNumber' => 'AA123',
            'ticketStatus' => 'ISSUED',
            'totalAmount' => 250.00,
            'currency' => 'USD',
            'issuedAt' => '2024-01-01T10:00:00Z'
          }
        ],
        'ticketStatus' => 'ISSUED',
        'issuedAt' => '2024-01-01T10:00:00Z'
      }
    end

    context 'with valid booking ID' do
      it 'retrieves flight tickets successfully' do
        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}/tickets")
          .and_return(success_response)

        result = service.call(booking_id)

        expect(result[:booking_id]).to eq('BK123456')
        expect(result[:ticket_status]).to eq('ISSUED')
        expect(result[:issued_at]).to eq('2024-01-01T10:00:00Z')
        expect(result[:tickets].length).to eq(2)

        first_ticket = result[:tickets].first
        expect(first_ticket[:ticket_number]).to eq('1234567890123')
        expect(first_ticket[:passenger_name]).to eq('JOHN DOE')
        expect(first_ticket[:flight_number]).to eq('AA123')
        expect(first_ticket[:ticket_status]).to eq('ISSUED')
        expect(first_ticket[:total_amount]).to eq(250.00)
        expect(first_ticket[:currency]).to eq('USD')
        expect(first_ticket[:issued_at]).to eq('2024-01-01T10:00:00Z')
      end

      it 'handles booking with no tickets' do
        no_tickets_response = {
          'bookingId' => 'BK123456',
          'tickets' => [],
          'ticketStatus' => 'NOT_ISSUED'
        }

        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}/tickets")
          .and_return(no_tickets_response)

        result = service.call(booking_id)

        expect(result[:booking_id]).to eq('BK123456')
        expect(result[:ticket_status]).to eq('NOT_ISSUED')
        expect(result[:tickets]).to be_empty
      end

      it 'handles booking with pending tickets' do
        pending_response = {
          'bookingId' => 'BK123456',
          'tickets' => [
            {
              'ticketNumber' => '1234567890123',
              'passengerName' => 'JOHN DOE',
              'flightNumber' => 'AA123',
              'ticketStatus' => 'PENDING',
              'totalAmount' => 250.00,
              'currency' => 'USD'
            }
          ],
          'ticketStatus' => 'PENDING'
        }

        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}/tickets")
          .and_return(pending_response)

        result = service.call(booking_id)

        expect(result[:ticket_status]).to eq('PENDING')
        expect(result[:tickets].first[:ticket_status]).to eq('PENDING')
      end
    end

    context 'with invalid booking ID' do
      it 'raises error when booking ID is empty' do
        expect { service.call('') }.to raise_error(
          SabreApiRuby::ValidationError,
          'Booking ID is required'
        )
      end

      it 'raises error when booking ID is nil' do
        expect { service.call(nil) }.to raise_error(
          SabreApiRuby::ValidationError,
          'Booking ID is required'
        )
      end

      it 'raises error when booking ID is blank' do
        expect { service.call('   ') }.to raise_error(
          SabreApiRuby::ValidationError,
          'Booking ID is required'
        )
      end
    end

    context 'with API errors' do
      it 'propagates NotFoundError from client' do
        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}/tickets")
          .and_raise(SabreApiRuby::NotFoundError.new('Not Found', 404, 'BOOKING_NOT_FOUND', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::NotFoundError)
      end

      it 'propagates AuthenticationError from client' do
        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}/tickets")
          .and_raise(SabreApiRuby::AuthenticationError.new('Unauthorized', 401, 'UNAUTHORIZED', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::AuthenticationError)
      end

      it 'propagates ValidationError from client' do
        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}/tickets")
          .and_raise(SabreApiRuby::ValidationError.new('Bad Request', 400, 'INVALID_REQUEST', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::ValidationError)
      end
    end
  end
end
