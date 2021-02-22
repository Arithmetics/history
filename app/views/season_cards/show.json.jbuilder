json.season_cards @season_card_ownerships do |season_card_ownership|
  json.extract! season_card_ownership, :serial_number

  json.extract! season_card_ownership.season_card, :id, :auction_price, :breakout, :repeat, :champion

  json.extract! season_card_ownership.season_card_effect, :id, :name, :color_one, :color_two, :effect_image_url

  json.extract! season_card_ownership.season_card.season_stat, :year, :passing_yards, :passing_touchdowns, :rushing_yards, :rushing_touchdowns, :receiving_yards, :receiving_touchdowns, :receptions, :age_at_season, :experience_at_season, :position, :rank_reg, :rank_ppr, :fantasy_points_ppr, :fantasy_points_reg

  json.player do
    json.extract! season_card_ownership.season_card.season_stat.player, :id, :name, :nfl_URL_name, :picture_id
  end

  json.owner do
    json.extract! season_card_ownership.season_card.owner, :id, :name
  end
end