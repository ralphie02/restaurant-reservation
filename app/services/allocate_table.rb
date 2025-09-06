# Simple Allocation Strategy to pick the smallest capacity table that fits the party_size
#
class AllocateTable
  def self.call(party_size:, period:)
    # Hardcoded 1st Restaurant for now...
    restaurant = Restaurant.first
    table_id_subquery = Reservation.
      where("reservations.table_id = tables.id").
      where("reservations.period && tsrange(?, ?, '[)')", period.begin, period.end).
      select(:table_id)
    restaurant.tables.
      where(capacity: party_size..).
      where.not(id: table_id_subquery).
      asc_capacity.
      first
  end
end
