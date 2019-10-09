order = ["QB", "RB", "WR", "TE", "Q/R/W/T", "DEF", "K", "BN", "RES"]

json.fantasy_team do
  json.extract! @fantasy_team, :id, :name, :year

  json.owner @fantasy_team.owner, partial: "owners/owner", as: :owner

  json.fantasy_starts do
    @fantasy_team.fantasy_starts.group_by(&:week).each do |week, starts|
      json.set! week do
        json.array! starts do |start|
          json.extract! start, :id, :week, :position, :points
          json.player start.player, partial: "players/player", as: :player
        end
        #  starts.sort_by { |s| order.index(s.position) }
      end
    end

    # has_ones:
    # json.contact @property.contact
  end
end
