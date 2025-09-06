require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe 'associations' do
    it { should have_many(:tables) }
    it { should have_many(:reservations).through(:tables) }
  end
end
