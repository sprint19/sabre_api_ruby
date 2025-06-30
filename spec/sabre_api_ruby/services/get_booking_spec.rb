# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SabreApiRuby::Services::GetBooking do
  let(:client) { instance_double(SabreApiRuby::Client) }
  let(:service) { described_class.new(client) }

  describe '#call' do
    let(:booking_id) { 'BK123456' }
    let(:success_response) do
      {
        'bookingId' => 'BK123456',
        'confirmationNumber' => 'ABC123',
        'status' => 'CONFIRMED',
        'passengers' => [
          {
            'type' => 'ADT',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'dateOfBirth' => '1990-01-01'
          }
        ],
        'flights' => [
          {
            'origin' => 'LAX',
            'destination' => 'JFK',
            'departureDate' => '2024-01-15',
            'airline' => 'AA',
            'flightNumber' => '123'
          }
        ],
        'pricing' => {
          'currency' => 'USD',
          'total' => 500.00
        },
        'contactInfo' => {
          'email' => 'john.doe@example.com',
          'phone' => '+1234567890'
        },
        'createdAt' => '2024-01-01T10:00:00Z',
        'updatedAt' => '2024-01-01T10:00:00Z'
      }
    end

    context 'with valid booking ID' do
      it 'retrieves booking details successfully' do
        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}")
          .and_return(success_response)

        result = service.call(booking_id)

        expect(result[:booking_id]).to eq('BK123456')
        expect(result[:confirmation_number]).to eq('ABC123')
        expect(result[:status]).to eq('CONFIRMED')
        expect(result[:passengers]).to eq(success_response['passengers'])
        expect(result[:flights]).to eq(success_response['flights'])
        expect(result[:pricing]).to eq(success_response['pricing'])
        expect(result[:contact_info]).to eq(success_response['contactInfo'])
        expect(result[:created_at]).to eq('2024-01-01T10:00:00Z')
        expect(result[:updated_at]).to eq('2024-01-01T10:00:00Z')
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
          .with(:get, "/booking/#{booking_id}")
          .and_raise(SabreApiRuby::NotFoundError.new('Not Found', 404, 'BOOKING_NOT_FOUND', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::NotFoundError)
      end

      it 'propagates AuthenticationError from client' do
        expect(client).to receive(:request)
          .with(:get, "/booking/#{booking_id}")
          .and_raise(SabreApiRuby::AuthenticationError.new('Unauthorized', 401, 'UNAUTHORIZED', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::AuthenticationError)
      end
    end
  end
end
