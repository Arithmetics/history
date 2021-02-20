json.season_cards @season_cards do |season_card|
  json.extract! season_card, :id, :auction_price, :breakout, :repeat, :champion
  json.extract! season_card.season_stat, :year, :passing_yards, :passing_touchdowns, :rushing_yards, :rushing_touchdowns, :receiving_yards, :receiving_touchdowns, :receptions, :age_at_season, :experience_at_season, :position, :rank_reg, :rank_ppr, :fantasy_points_ppr, :fantasy_points_reg
  json.player do
    json.extract! season_card.season_stat.player, :id, :name, :nfl_URL_name, :picture_id
  end

  json.users do 
    json.array! season_card.users do |user|
      json.extract! user.owner, :id, :name
    end
  end

end