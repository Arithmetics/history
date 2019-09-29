class Owner < ApplicationRecord
  validates_uniqueness_of :name
  validates :name, presence: true

  has_many :fantasy_teams
end
