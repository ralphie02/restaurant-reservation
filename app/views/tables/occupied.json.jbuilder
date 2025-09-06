json.tables @tables.each do |table|
  json.id table.id
  json.capacity table.capacity
  json.reservation_id table.reservations.first.id
  json.party_size table.reservations.first.party_size
end
