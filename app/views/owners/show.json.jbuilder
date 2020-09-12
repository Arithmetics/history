json.owner do
  json.extract! @owner, :id, :name

  json.set! "cumulative_stats", @owner.cumulative_stats.deep_transform_keys! { |key| key.camelize(:lower) }

  json.set! "versus_records", @owner.versus_records

  json.fantasy_teams @owner.fantasy_teams do |fantasy_team|
    json.extract! fantasy_team, :id, :name, :year, :season_wins, :season_losses, :season_points, :made_playoffs?, :made_finals?, :won_championship?
  end
end
