order = ["QB", "RB", "WR", "TE", "Q/R/W/T", "DEF", "K", "BN", "RES"]

json.fantasy_team do
  json.extract! @fantasy_team, :id, :name, :year

  json.owner @fantasy_team.owner, partial: "owners/owner", as: :owner

  json.purchases do
    json.array! @fantasy_team.purchases.order(price: :desc) do |purchase|
      json.extract! purchase, :id, :price, :position, :year

      json.player do
        json.extract! purchase.player, :id, :name
      end
    end
  end

  json.fantasy_starts do
    @fantasy_team.fantasy_starts.group_by(&:week).each do |week, starts|
      json.set! week do
        json.array! starts.sort_by { |start| order.index(start.position) } do |start|
          json.extract! start, :id, :week, :position, :points
          json.player start.player, partial: "players/player", as: :player
        end
      end
    end
  end
end
