class SeasonCardOwnership < ApplicationRecord
  belongs_to :user
  belongs_to :season_card
  belongs_to :season_card_effect
end
