require "rails_helper"

RSpec.describe CreateReservation do
  describe "#call" do
    subject(:call_service) { described_class.call(params: params, reservation: reservation) }

    let(:params) do
      {
        party_size: '2',
        duration: '1',
        start_time: start_time_string
      }
    end
    let(:start_time_string) { '2025-09-05 13:00:00 -0700' }
    let(:start_time) { Time.parse(start_time_string) }
    let(:saved) { true }
    let(:reservation) { instance_double(Reservation, errors: errors, save: saved) }
    let(:errors) { instance_double(ActiveModel::Errors) }
    let(:period) { start_time...(start_time + 1.hour) }

    before do
      allow(AllocateTable).to receive(:call).with(party_size: 2, period: period).and_return(table)
      allow(errors).to receive(:add)
      allow(reservation).to receive(:assign_attributes)
    end

    context "when table is blank" do
      let(:table) { nil }

      it "adds error message 'No available table'" do
        call_service
        expect(errors).to have_received(:add).with(:base, "No available table")
      end
    end

    context "when table is present" do
      let(:table) { instance_double(Table) }

      it "calls assign_attributes with params" do
        call_service
        expect(reservation).to have_received(:assign_attributes).
          with(
            party_size: 2,
            duration: 1,
            start_time: start_time,
            period: period,
            table: table
          )
      end

      it { is_expected.to eq saved }
    end
  end
end
