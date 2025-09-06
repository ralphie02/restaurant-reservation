require 'rails_helper'

RSpec.describe ReservationsController, type: :controller do
  describe 'POST #show' do
    subject(:make_request) { post :create, params: params, as: :json }

    let(:params) { { party_size: '1', duration: '2', start_time: '2026-01-01T12:00:00Z' } }

    context "when resevation with idempotency_key is nil" do
      before do
        request.headers["Idempotency-Key"] = nil
      end

      it "responds with bad_request" do
        make_request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when resevation with idempotency_key is found and persisted" do
      let(:idempotency_key) { '1234' }
      let(:reservation) { Reservation.new }

      before do
        request.headers["Idempotency-Key"] = idempotency_key
        allow(Reservation).to receive(:find_or_initialize_by).with(idempotency_key: idempotency_key).
          and_return(reservation)
        allow(reservation).to receive(:persisted?).and_return(persisted?)
      end

      context "when reservation persists" do
        let(:persisted?) { true }

        it "responds with ok" do
          make_request
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(reservation.to_json)
        end
      end

      context "when reservation does not persist" do
        let(:persisted?) { false }

        before do
          allow(CreateReservation).to receive(:call).
            with(params: ActionController::Parameters.new(params).permit!, reservation: reservation).
            and_return(success?)
        end

        context "when CreateReservation succeeds" do
          let(:success?) { true }

          it "responds with created" do
            make_request
            expect(response).to have_http_status(:created)
            expect(response.body).to eq(reservation.to_json)
          end
        end

        context "when CreateReservation fails" do
          let(:success?) { false }

          it "responds with unprocessable_entity" do
            make_request
            expect(response).to have_http_status(422)
            expect(response.body).to eq({ errors: reservation.errors.full_messages }.to_json)
          end
        end
      end
    end
  end
end
