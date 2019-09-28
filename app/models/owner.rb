class Owner < ApplicationRecord
  validates_uniqueness_of :name

  has_many :fantasy_teams
end
