class FantasyTeam < ApplicationRecord
  belongs_to :owner
  validates :name, presence: true
  validates :year, presence: true
end
