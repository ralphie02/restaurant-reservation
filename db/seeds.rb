# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
restaurant = Restaurant.create(name: "Test Resto")
current_time = Time.current
restaurant.tables.insert_all(
  [1, 2, 4, 6, 8].map { |n| { capacity: n, created_at: current_time, updated_at: current_time } }
)
table_capac_2 = Table.find_by(capacity: 2)
table_capac_4 = Table.find_by(capacity: 4)
time_12 = Time.new(2026, 1, 1, 12)
table_capac_2.reservations.create(party_size: 2, duration: 2, start_time: time_12, period: time_12...(time_12 + 2.hours))
table_capac_4.reservations.create(party_size: 4, duration: 3, start_time: time_12, period: time_12...(time_12 + 3.hours))
