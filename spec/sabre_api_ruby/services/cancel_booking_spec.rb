# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SabreApiRuby::Services::CancelBooking do
  let(:client) { instance_double(SabreApiRuby::Client) }
  let(:service) { described_class.new(client) }

  describe '#call' do
    let(:booking_id) { 'BK123456' }
    let(:success_response) do
      {
        'bookingId' => 'BK123456',
        'status' => 'CANCELLED',
        'cancellationNumber' => 'CN789012',
        'cancelledAt' => '2024-01-01T10:00:00Z',
        'refundInfo' => {
          'method' => 'ORIGINAL_PAYMENT',
          'amount' => 500.00,
          'currency' => 'USD'
        },
        'remarks' => 'Cancelled due to schedule change'
      }
    end

    context 'with valid parameters' do
      it 'cancels a booking successfully' do
        params = { reason: 'Customer request', remarks: 'Cancelled due to schedule change' }

        expect(client).to receive(:request)
          .with(:post, "/booking/#{booking_id}/cancel", params)
          .and_return(success_response)

        result = service.call(booking_id, params)

        expect(result[:booking_id]).to eq('BK123456')
        expect(result[:status]).to eq('CANCELLED')
        expect(result[:cancellation_number]).to eq('CN789012')
        expect(result[:cancelled_at]).to eq('2024-01-01T10:00:00Z')
        expect(result[:refund_info]).to eq(success_response['refundInfo'])
        expect(result[:remarks]).to eq('Cancelled due to schedule change')
      end

      it 'cancels booking with refund request' do
        params = {
          reason: 'Customer request',
          refund_request: {
            method: 'ORIGINAL_PAYMENT',
            amount: 500.00,
            currency: 'USD'
          }
        }

        expected_params = {
          reason: 'Customer request',
          refundRequest: {
            method: 'ORIGINAL_PAYMENT',
            amount: 500.00,
            currency: 'USD'
          }
        }

        expect(client).to receive(:request)
          .with(:post, "/booking/#{booking_id}/cancel", expected_params)
          .and_return(success_response)

        service.call(booking_id, params)
      end

      it 'cancels booking with minimal parameters' do
        expect(client).to receive(:request)
          .with(:post, "/booking/#{booking_id}/cancel", {})
          .and_return(success_response)

        service.call(booking_id)
      end
    end

    context 'with invalid parameters' do
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

      it 'raises error when params is not a hash' do
        expect { service.call(booking_id, 'invalid') }.to raise_error(
          SabreApiRuby::ValidationError,
          'Parameters must be a hash'
        )
      end
    end

    context 'with API errors' do
      it 'propagates NotFoundError from client' do
        expect(client).to receive(:request)
          .with(:post, "/booking/#{booking_id}/cancel", {})
          .and_raise(SabreApiRuby::NotFoundError.new('Not Found', 404, 'BOOKING_NOT_FOUND', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::NotFoundError)
      end

      it 'propagates ValidationError from client' do
        expect(client).to receive(:request)
          .with(:post, "/booking/#{booking_id}/cancel", {})
          .and_raise(SabreApiRuby::ValidationError.new('Bad Request', 400, 'INVALID_REQUEST', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::ValidationError)
      end

      it 'propagates AuthenticationError from client' do
        expect(client).to receive(:request)
          .with(:post, "/booking/#{booking_id}/cancel", {})
          .and_raise(SabreApiRuby::AuthenticationError.new('Unauthorized', 401, 'UNAUTHORIZED', {}))

        expect { service.call(booking_id) }.to raise_error(SabreApiRuby::AuthenticationError)
      end
    end
  end
end
