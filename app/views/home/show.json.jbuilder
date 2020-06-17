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

json.versus_records do
  json.array! @owners do |owner|
    json.extract! owner, :id, :name

    json.set! "versus_records", owner.versus_records
  end
end

json.first_starts do
  json.array! @first_starts do |start|
    json.extract! start, :id, :week, :position, :points
    json.player do
      json.extract! start.player, :id, :name
    end
    json.fantasy_team do
      json.extract! start.fantasy_team, :id, :name
    end
  end
end
