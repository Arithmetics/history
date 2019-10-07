

json.fantasy_team do
  json.extract! @fantasy_team, :id, :name, :year

  json.owner @fantasy_team.owner, partial: "owners/owner", as: :owner

  json.fantasy_starts @fantasy_team.fantasy_starts do |start|
    json.extract! start, :id, :week, :position, :points
    json.player start.player, partial: "players/player", as: :player
  end
end
