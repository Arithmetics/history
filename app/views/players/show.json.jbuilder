json.player do
  json.extract! @player, :id, :name, :birthdate

  json.purchases do
    json.array! @player.purchases.order(year: :desc) do |purchase|
      json.extract! purchase, :id, :price, :position, :year

      json.fantasy_team do
        json.extract! purchase.fantasy_team, :id, :name
      end

      json.owner do
        json.extract! purchase.fantasy_team.owner, :id, :name
      end
    end
  end

  json.season_stats do
    json.array! @player.season_stats.order(year: :desc).select { |s| s.year > 2010 } do |stat|
      json.extract! stat, :games_played, :year, :passing_completions, :passing_attempts, :passing_yards, :passing_touchdowns, :interceptions, :rushing_attempts, :rushing_yards, :rushing_touchdowns, :receiving_yards, :receptions, :receiving_touchdowns, :fumbles_lost, :age_at_season, :experience_at_season, :fantasy_points_reg, :fantasy_points_ppr, :rank_reg, :rank_ppr
    end
  end

  json.fantasy_starts do
    json.array! @player.fantasy_starts do |start|
      json.extract! start, :id, :week, :position, :points, :year

      json.fantasy_team do
        json.extract! start.fantasy_team, :name, :id
      end

      json.owner do
        json.extract! start.fantasy_team.owner, :name, :id
      end
    end
  end
end
