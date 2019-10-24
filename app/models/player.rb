class Player < ApplicationRecord
  has_many :fantasy_starts
  has_many :purchases
  validates :name, presence: true
end
