# Allocation strategy to select the available table for a give party_size and period.
# It prioritizes the smallest table that can accommodate the party_size.
#
# @example
#   AllocateTable.call(party_size: party_size, period: period)
#
# @param [Integer] party_size. Size of reservation
# @param [Range] period. Time range for the reservation
#
# @return [Table] table record or nil
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
