class Purchase < ApplicationRecord
  belongs_to :fantasy_team
  belongs_to :player
end
