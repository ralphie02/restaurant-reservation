class Reservation < ApplicationRecord
  belongs_to :table

  validates :party_size, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :start_time, presence: true
  validates :period, presence: true
  validate :no_table_period_overlap
  validate :party_size_within_table_capacity

  scope :overlapping, ->(range, ref_id) {
    where(table_id: ref_id).
    where("period && tsrange(?, ?, '[)')", range.begin, range.end)
  }

  private

  def no_table_period_overlap
    return if period.blank? || table_id.blank?

    if Reservation.overlapping(period, table_id).where.not(id: id).exists?
      errors.add(:period, "overlaps with another reservation")
    end
  end

  def party_size_within_table_capacity
    return if party_size.blank? || table.blank?

    errors.add(:party_size, "cannot be more than the table capacity") if party_size > table.capacity
  end
end
