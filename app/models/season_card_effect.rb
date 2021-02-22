class SeasonCardEffect < ApplicationRecord
  has_many :season_card_ownerships

  self.get_random_effect
    count = SeasonCardEffect.count
    random_offset = rand(count)
    random_user = SeasonCardEffect.offset(random_offset).first
  end
end
