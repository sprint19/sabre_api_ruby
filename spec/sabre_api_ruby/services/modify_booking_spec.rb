# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SabreApiRuby::Services::ModifyBooking do
  let(:client) { instance_double(SabreApiRuby::Client) }
  let(:service) { described_class.new(client) }

  describe '#call' do
    let(:booking_id) { 'BK123456' }
    let(:success_response) do
      {
        'bookingId' => 'BK123456',
        'confirmationNumber' => 'ABC123',
        'status' => 'MODIFIED',
        'passengers' => [
          {
            'type' => 'ADT',
            'firstName' => 'John',
            'lastName' => 'Smith',
            'dateOfBirth' => '1990-01-01'
          }
        ],
        'flights' => [
          {
            'origin' => 'LAX',
            'destination' => 'JFK',
            'departureDate' => '2024-01-16',
            'airline' => 'AA',
            'flightNumber' => '124'
          }
        ],
        'pricing' => {
          'currency' => 'USD',
          'total' => 550.00
        },
        'contactInfo' => {
          'email' => 'john.smith@example.com',
          'phone' => '+1234567890'
        },
        'remarks' => 'Updated contact information',
        'modifiedAt' => '2024-01-01T10:00:00Z'
      }
    end

    let(:valid_params) do
      {
        passengers: [
          {
            type: 'ADT',
            firstName: 'John',
            lastName: 'Smith',
            dateOfBirth: '1990-01-01'
          }
        ],
        flights: [
          {
            origin: 'LAX',
            destination: 'JFK',
            departureDate: '2024-01-16',
            airline: 'AA',
            flightNumber: '124'
          }
        ],
        contact_info: {
          email: 'john.smith@example.com'
        },
        remarks: 'Updated contact information'
      }
    end

    context 'with valid parameters' do
      it 'modifies a booking successfully' do
        expect(client).to receive(:request)
          .with(:put, "/booking/#{booking_id}", build_request_body(valid_params))
          .and_return(success_response)

        result = service.call(booking_id, valid_params)

        expect(result[:booking_id]).to eq('BK123456')
        expect(result[:confirmation_number]).to eq('ABC123')
        expect(result[:status]).to eq('MODIFIED')
        expect(result[:passengers]).to eq(success_response['passengers'])
        expect(result[:flights]).to eq(success_response['flights'])
        expect(result[:pricing]).to eq(success_response['pricing'])
        expect(result[:contact_info]).to eq(success_response['contactInfo'])
        expect(result[:remarks]).to eq('Updated contact information')
        expect(result[:modified_at]).to eq('2024-01-01T10:00:00Z')
      end

      it 'modifies booking with only passenger changes' do
        passenger_only_params = { passengers: valid_params[:passengers] }

        expect(client).to receive(:request)
          .with(:put, "/booking/#{booking_id}", build_request_body(passenger_only_params))
          .and_return(success_response)

        service.call(booking_id, passenger_only_params)
      end

      it 'modifies booking with only flight changes' do
        flight_only_params = { flights: valid_params[:flights] }

        expect(client).to receive(:request)
          .with(:put, "/booking/#{booking_id}", build_request_body(flight_only_params))
          .and_return(success_response)

        service.call(booking_id, flight_only_params)
      end

      it 'modifies booking with only contact info changes' do
        contact_only_params = { contact_info: valid_params[:contact_info] }

        expect(client).to receive(:request)
          .with(:put, "/booking/#{booking_id}", build_request_body(contact_only_params))
          .and_return(success_response)

        service.call(booking_id, contact_only_params)
      end
    end

    context 'with invalid parameters' do
      it 'raises error when booking ID is empty' do
        expect { service.call('', valid_params) }.to raise_error(
          SabreApiRuby::ValidationError,
          'Booking ID is required'
        )
      end

      it 'raises error when booking ID is nil' do
        expect { service.call(nil, valid_params) }.to raise_error(
          SabreApiRuby::ValidationError,
          'Booking ID is required'
        )
      end

      it 'raises error when booking ID is blank' do
        expect { service.call('   ', valid_params) }.to raise_error(
          SabreApiRuby::ValidationError,
          'Booking ID is required'
        )
      end

      it 'raises error when params is not a hash' do
        expect { service.call(booking_id, 'invalid') }.to raise_error(
          SabreApiRuby::ValidationError,
          'Parameters must be a hash'
        )
      end

      it 'raises error when params is empty' do
        expect { service.call(booking_id, {}) }.to raise_error(
          SabreApiRuby::ValidationError,
          'At least one modification parameter is required'
        )
      end

      it 'raises error when passenger is missing required fields' do
        invalid_passenger_params = {
          passengers: [
            { firstName: 'John' } # Missing type and lastName
          ]
        }

        expect { service.call(booking_id, invalid_passenger_params) }.to raise_error(
          SabreApiRuby::ValidationError,
          'Passenger 1 missing required fields: type, lastName'
        )
      end

      it 'raises error when flight is missing required fields' do
        invalid_flight_params = {
          flights: [
            { origin: 'LAX' } # Missing destination and departureDate
          ]
        }

        expect { service.call(booking_id, invalid_flight_params) }.to raise_error(
          SabreApiRuby::ValidationError,
          'Flight 1 missing required fields: destination, departureDate'
        )
      end
    end

    context 'with API errors' do
      it 'propagates NotFoundError from client' do
        expect(client).to receive(:request)
          .with(:put, "/booking/#{booking_id}", build_request_body(valid_params))
          .and_raise(SabreApiRuby::NotFoundError.new('Not Found', 404, 'BOOKING_NOT_FOUND', {}))

        expect { service.call(booking_id, valid_params) }.to raise_error(SabreApiRuby::NotFoundError)
      end

      it 'propagates ValidationError from client' do
        expect(client).to receive(:request)
          .with(:put, "/booking/#{booking_id}", build_request_body(valid_params))
          .and_raise(SabreApiRuby::ValidationError.new('Bad Request', 400, 'INVALID_REQUEST', {}))

        expect { service.call(booking_id, valid_params) }.to raise_error(SabreApiRuby::ValidationError)
      end

      it 'propagates AuthenticationError from client' do
        expect(client).to receive(:request)
          .with(:put, "/booking/#{booking_id}", build_request_body(valid_params))
          .and_raise(SabreApiRuby::AuthenticationError.new('Unauthorized', 401, 'UNAUTHORIZED', {}))

        expect { service.call(booking_id, valid_params) }.to raise_error(SabreApiRuby::AuthenticationError)
      end
    end
  end

  private

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
end
