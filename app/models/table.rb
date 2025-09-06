class Table < ApplicationRecord
  has_many :reservations, dependent: :destroy
  belongs_to :restaurant

  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :asc_capacity, -> { order(:capacity) }
  scope :reserved_at, ->(timestamp) { joins(:reservations).where("reservations.period @> ?::timestamp", timestamp) }
end
