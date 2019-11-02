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
