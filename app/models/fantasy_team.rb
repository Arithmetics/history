class FantasyTeam < ApplicationRecord
  belongs_to :owner
  has_many :fantasy_starts

  validates :name, presence: true
  validates :year, presence: true
end
