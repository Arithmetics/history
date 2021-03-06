json.player do
  json.extract! @player, :id, :name, :birthdate, :picture_id
  json.set! "career_stats", @player.career_stats.deep_transform_keys! { |key| key.camelize(:lower) }

  json.purchases do
    json.array! @player.purchases.order(year: :desc) do |purchase|
      json.extract! purchase, :id, :price, :position, :year

      json.fantasy_team do
        json.extract! purchase.fantasy_team, :id, :name, :picture_url
      end

      json.owner do
        json.extract! purchase.fantasy_team.owner, :id, :name
      end
    end
  end

  json.season_stats do
    players_ranks = @player.rankings.all
    json.array! @player.season_stats.order(year: :desc).select { |s| s.year > 2010 } do |stat|
      year_rank = players_ranks.select { |r| r.year == stat.year }
      json.extract! stat, :games_played, :year, :passing_completions, :passing_attempts, :passing_yards, :passing_touchdowns, :interceptions, :rushing_attempts, :rushing_yards, :rushing_touchdowns, :receiving_yards, :receptions, :receiving_touchdowns, :fumbles_lost, :age_at_season, :experience_at_season, :fantasy_points_reg, :fantasy_points_ppr, :rank_reg, :rank_ppr
      if year_rank.length() == 1
        json.set! "preseasonRank", year_rank[0].ranking
      end
    end
  end

  json.fantasy_starts do
    json.array! @player.fantasy_starts do |start|
      json.extract! start, :id, :week, :position, :points, :year

      json.fantasy_team do
        json.extract! start.fantasy_team, :name, :id, :picture_url
      end

      json.owner do
        json.extract! start.fantasy_team.owner, :name, :id
      end
    end
  end
end
