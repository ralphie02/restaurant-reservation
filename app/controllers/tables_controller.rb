class TablesController < ApplicationController
  def occupied
    # Hardcoded 1st Restaurant for now...
    restaurant = Restaurant.first

    @tables = restaurant.tables.reserved_at(Time.parse(params[:at]))
  end
end
