class Restaurant < ApplicationRecord
  has_many :tables, dependent: :destroy
  has_many :reservations, through: :tables, dependent: :destroy
end
