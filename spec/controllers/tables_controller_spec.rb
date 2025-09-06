require 'rails_helper'

RSpec.describe TablesController, type: :controller do
  describe 'GET #occupied' do
    subject(:make_request) { get :occupied, params: params, as: :json }

    let(:params) { { at: "2025-09-05 12:00:00 -0700" } }
    let(:time) { Time.new(2025, 1, 1, 12) }
    let(:tables) { class_double(Table) }
    let(:restaurant) { instance_double(Restaurant, tables: tables) }

    before do
      allow(Restaurant).to receive(:first).and_return(restaurant)
      allow(Time).to receive(:parse).with(params[:at]).and_return(time)
      allow(tables).to receive(:reserved_at).with(time).and_return(tables)
    end

    it "assigns tables" do
      make_request
      expect(assigns(:tables)).to eq(tables)
    end
  end
end
