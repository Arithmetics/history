json.player do
  json.extract! @player, :id, :name, :birthdate

  json.fantasy_starts do
    json.array! @player.fantasy_starts do |start|
      json.extract! start, :week, :position, :points

      json.fantasy_team do
        json.extract! start.fantasy_team, :name
      end

      json.owner do
        json.extract! start.fantasy_team.owner, :name, :id
      end
    end
  end
end
