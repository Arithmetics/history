json.owner do
  json.extract! @owner, :id, :name

  json.set! "cumulative_stats", @owner.cumulative_stats.deep_transform_keys! { |key| key.camelize(:lower) }

  json.fantasy_teams @owner.fantasy_teams do |fantasy_team|
    json.extract! fantasy_team, :id, :name, :year, :season_wins, :season_points
  end
end
