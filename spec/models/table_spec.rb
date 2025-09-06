require 'rails_helper'

RSpec.describe Table, type: :model do
  describe 'associations' do
    it { should have_many(:reservations) }
    it { should belong_to(:restaurant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:capacity) }
    it { should validate_numericality_of(:capacity).is_greater_than(0) }
    it { should validate_numericality_of(:capacity).only_integer }
  end

  describe '.reserved_at' do
    let(:restaurant) { create(:restaurant) }
    let(:table_reserved_at_12_for_2) { create(:table, restaurant: restaurant) }
    let(:table_reserved_at_12_for_1) { create(:table, restaurant: restaurant) }
    let(:start_at_12) { Time.now.change(hour: 12) }
    let!(:reservation_12_2hr) do
      create(
        :reservation,
        start_time: start_at_12,
        duration: 2,
        period: start_at_12...(start_at_12 + 2.hours),
        table: table_reserved_at_12_for_2
      )
    end
    let!(:reservation_12_1hr) do
      create(
        :reservation,
        start_time: start_at_12,
        duration: 1,
        period: start_at_12...(start_at_12 + 1.hours),
        table: table_reserved_at_12_for_1
      )
    end

    it 'returns table_reserved_at_12_for_2 and table_reserved_at_12_for_1' do
      expect(Table.reserved_at(start_at_12)).to include(table_reserved_at_12_for_2, table_reserved_at_12_for_1)
    end

    it 'returns table_reserved_at_12_for_2' do
      expect(Table.reserved_at(start_at_12 + 1.hours)).to include(table_reserved_at_12_for_2)
    end

    it 'returns nothing' do
      expect(Table.reserved_at(start_at_12 + 2.hours)).to eq([])
    end
  end
end
