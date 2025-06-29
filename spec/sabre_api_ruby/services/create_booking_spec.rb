# frozen_string_literal: true

require "spec_helper"

RSpec.describe SabreApiRuby::Services::CreateBooking do
  let(:client) { instance_double(SabreApiRuby::Client) }
  let(:service) { described_class.new(client) }

  describe "#call" do
    let(:valid_params) do
      {
        passengers: [
          {
            type: "ADT",
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: "1990-01-01"
          }
        ],
        flights: [
          {
            origin: "LAX",
            destination: "JFK",
            departureDate: "2024-01-15",
            airline: "AA",
            flightNumber: "123"
          }
        ]
      }
    end

    let(:success_response) do
      {
        "bookingId" => "BK123456",
        "confirmationNumber" => "ABC123",
        "status" => "CONFIRMED",
        "passengers" => valid_params[:passengers],
        "flights" => valid_params[:flights],
        "createdAt" => "2024-01-01T10:00:00Z"
      }
    end

    context "with valid parameters" do
      it "creates a booking successfully" do
        expect(client).to receive(:request)
          .with(:post, "/booking/create", build_request_body(valid_params))
          .and_return(success_response)

        result = service.call(valid_params)

        expect(result[:booking_id]).to eq("BK123456")
        expect(result[:confirmation_number]).to eq("ABC123")
        expect(result[:status]).to eq("CONFIRMED")
        expect(result[:passengers]).to eq(valid_params[:passengers])
        expect(result[:flights]).to eq(valid_params[:flights])
      end

      it "includes optional parameters in request" do
        params_with_optional = valid_params.merge(
          pricing: { currency: "USD", total: 500.00 },
          payment: { method: "CREDIT_CARD" },
          contact_info: { email: "test@example.com" },
          remarks: "Special request",
          ticketing: { timeLimit: "2024-01-02T10:00:00Z" }
        )

        expect(client).to receive(:request)
          .with(:post, "/booking/create", build_request_body(params_with_optional))
          .and_return(success_response)

        service.call(params_with_optional)
      end
    end

    context "with invalid parameters" do
      it "raises error when passengers are missing" do
        params = valid_params.except(:passengers)
        
        expect { service.call(params) }.to raise_error(
          SabreApiRuby::ValidationError,
          "Missing required fields: passengers"
        )
      end

      it "raises error when flights are missing" do
        params = valid_params.except(:flights)
        
        expect { service.call(params) }.to raise_error(
          SabreApiRuby::ValidationError,
          "Missing required fields: flights"
        )
      end

      it "raises error when passenger is missing required fields" do
        invalid_passenger_params = valid_params.dup
        invalid_passenger_params[:passengers] = [
          { firstName: "John" } # Missing type and lastName
        ]

        expect { service.call(invalid_passenger_params) }.to raise_error(
          SabreApiRuby::ValidationError,
          "Passenger 1 missing required fields: type, lastName"
        )
      end

      it "raises error when flight is missing required fields" do
        invalid_flight_params = valid_params.dup
        invalid_flight_params[:flights] = [
          { origin: "LAX" } # Missing destination and departureDate
        ]

        expect { service.call(invalid_flight_params) }.to raise_error(
          SabreApiRuby::ValidationError,
          "Flight 1 missing required fields: destination, departureDate"
        )
      end
    end

    context "with multiple passengers and flights" do
      let(:multiple_params) do
        {
          passengers: [
            { type: "ADT", firstName: "John", lastName: "Doe" },
            { type: "CHD", firstName: "Jane", lastName: "Doe" }
          ],
          flights: [
            { origin: "LAX", destination: "JFK", departureDate: "2024-01-15" },
            { origin: "JFK", destination: "LAX", departureDate: "2024-01-20" }
          ]
        }
      end

      it "validates all passengers and flights" do
        expect(client).to receive(:request)
          .with(:post, "/booking/create", build_request_body(multiple_params))
          .and_return(success_response)

        service.call(multiple_params)
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