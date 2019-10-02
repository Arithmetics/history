class Player < ApplicationRecord
  has_many :fantasy_starts
  validates :name, presence: true
end
