class WaiverBid < ApplicationRecord
  belongs_to :fantasy_team
  belongs_to :player

  validates :amount, presence: true
  validates :year, presence: true
  validates :week, presence: true
end
