require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:party_size) }
    it { should validate_numericality_of(:party_size).is_greater_than(0) }
    it { should validate_numericality_of(:party_size).only_integer }
    it { should validate_presence_of(:duration) }
    it { should validate_numericality_of(:duration).is_greater_than(0) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:period) }
  end

  describe 'associations' do
    it { should belong_to(:table) }
  end

  describe '.overlapping' do
    subject(:scope) { Reservation.overlapping(overlapping_period, reservation.table.id) }

    let(:reservation) { create(:reservation) }
    let(:start_at_12) { Time.now.change(hour: 12) }
    let(:overlapping_period) { overlapping_start...(overlapping_start + 2.hours) }

    context "period overlaps" do
      let(:overlapping_start) { Time.now.change(hour: 13) }

      it { is_expected.to include(reservation) }
    end

    context "period does NOT overlap" do
      let(:overlapping_start) { Time.now.change(hour: 14) }

      it { is_expected.to be_empty }
    end
  end

  context 'when validating no_table_period_overlap' do
    subject(:create_reservation) { create(:reservation, table: table) }

    let(:table) { create(:table) }

    context "when reservation is created on a table" do
      it 'creates a new reservation' do
        expect { create_reservation }.to change { Reservation.count }.by 1
      end
    end

    context "when reservation with the same period is created on the same table" do
      it 'raises ActiveRecord::RecordInvalid' do
        create(:reservation, table: table)
        expect { create_reservation }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context 'when validating party_size is within table capacity' do
    subject(:create_reservation) { create(:reservation, table: table) }

    let(:table) { create(:table, capacity: 1) }

    it 'raises ActiveRecord::RecordInvalid' do
      expect { create_reservation }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
