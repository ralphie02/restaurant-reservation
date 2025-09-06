require "rails_helper"

RSpec.describe AllocateTable do
  describe "#call" do
    let(:restaurant) { create(:restaurant) }
    let(:start_at_12) { Time.now.change(hour: 12) }
    let(:period) { start_at_12...(start_at_12 + 2.hours) }

    let!(:table_4) { create(:table, restaurant: restaurant, capacity: 4) }
    let!(:table_6) { create(:table, restaurant: restaurant, capacity: 6) }
    let!(:table_8) { create(:table, restaurant: restaurant, capacity: 8) }
    let!(:table_10) { create(:table, restaurant: restaurant, capacity: 10) }

    context "when table is available" do
      subject(:call_service) { described_class.call(party_size: 5, period: period) }

      it "books smallest table that can accomodate party" do
        expect(call_service).to eq(table_6)
      end
    end

    context "when the smallest table that can accomodate party is taken" do
      subject(:call_service) { described_class.call(party_size: 5, period: period) }

      let!(:table_6_reservation) do
        create(:reservation, start_time: start_at_12, duration: 2, period: period, table: table_6)
      end

      it "books the next available table" do
        expect(call_service).to eq(table_8)
      end
    end

    context "when table is taken now but free later" do
      subject(:call_service) { described_class.call(party_size: 5, period: period_15) }

      let(:start_time_15) { Time.now.change(hour: 15) }
      let(:period_15) { start_time_15...(start_time_15 + 2.hours) }
      let!(:table_6_reservation) do
        create(:reservation, start_time: start_at_12, duration: 2, period: period, table: table_6)
      end

      it "books smallest table that can accomodate party" do
        expect(call_service).to eq(table_6)
      end
    end

    context "when the party is too big" do
      subject(:call_service) { described_class.call(party_size: 11, period: period) }

      it "returns nil" do
        expect(call_service).to be_nil
      end
    end
  end
end
