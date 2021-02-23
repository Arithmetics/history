class SeasonCardEffect < ApplicationRecord
  has_many :season_card_ownerships

  def self.get_random_effect
    count = SeasonCardEffect.count
    random_offset = rand(count)
    return SeasonCardEffect.offset(random_offset).first
  end
end
