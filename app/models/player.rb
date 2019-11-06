class Player < ApplicationRecord
  has_many :fantasy_starts
  has_many :purchases
  has_many :season_stats
  validates :name, presence: true
end
