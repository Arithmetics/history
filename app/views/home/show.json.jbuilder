json.scheduled_games do
  json.array! @scheduled_games do |game|
    json.extract! game, :id, :week
    json.home_team do
      json.extract! game.home_fantasy_team, :id, :name
      json.owner do
        json.extract! game.home_fantasy_team.owner, :id, :name
      end
    end
    json.away_team do
      json.extract! game.away_fantasy_team, :id, :name
      json.owner do
        json.extract! game.away_fantasy_team.owner, :id, :name
      end
    end
  end
end
