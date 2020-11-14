json.scheduled_games do
  json.array! @scheduled_games do |game|
    json.extract! game, :id, :week
    json.home_team do
      json.extract! game.home_fantasy_team, :id, :name, :picture_url
      json.owner do
        json.extract! game.home_fantasy_team.owner, :id, :name
      end
    end
    json.away_team do
      json.extract! game.away_fantasy_team, :id, :name, :picture_url
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
      json.extract! start.player, :id, :name, :picture_id
    end
    json.fantasy_team do
      json.extract! start.fantasy_team, :id, :name, :picture_url
    end
  end
end

json.playoff_odds do
  json.array! @playoff_odds do |odd|
    json.extract! odd, :id, :year, :week, :odds, :category, :odds_with_win, :odds_with_loss
    json.fantasy_team do
      json.extract! odd.fantasy_team, :id, :name, :picture_url
    end
  end
end

json.standings do
  json.array! @standings do |fantasy_team|
    json.extract! fantasy_team, :id, :name, :picture_url
    json.set! "wins", fantasy_team.season_wins
    json.set! "losses", fantasy_team.season_losses
    json.set! "points", fantasy_team.season_points
    json.set! "topSixFinshes", fantasy_team.top_six_wins
    json.owner do
      json.extract! fantasy_team.owner, :id, :name
    end
  end
end
