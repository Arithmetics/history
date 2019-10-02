class FantasyStart < ApplicationRecord
  belongs_to :fantasy_team
  belongs_to :player

  validates :points, presence: true
  validates :year, presence: true
  validates_inclusion_of :week, :in => 1..16
  validates :position, presence: true, inclusion: { in: %w{QB RB WR TE DEF K BN Q/R/W/T RES} }
end
