order = ["QB", "RB", "WR", "TE", "Q/R/W/T", "DEF", "K", "BN", "RES"]
all_fantasy_games = (@fantasy_team.away_fantasy_games) + (@fantasy_team.home_fantasy_games)

json.fantasy_team do
  json.extract! @fantasy_team, :id, :name, :year

  json.cuumulative_stats do
    json.set! "season_points", @fantasy_team.season_points
    json.set! "season_wins", @fantasy_team.season_wins
  end

  json.fantasy_games do
    json.array! all_fantasy_games.sort { |a, b| a.week <=> b.week } do |game|
      json.extract! game, :id, :away_score, :home_score, :week
      json.home_team do
        json.extract! game.home_fantasy_team, :id, :name
        json.fantasy_starts do
          game.home_fantasy_team.fantasy_starts.group_by(&:week).each do |week, starts|
            json.set! week do
              json.array! starts.sort_by { |start| order.index(start.position) } do |start|
                json.extract! start, :id, :week, :position, :points
                json.player start.player, partial: "players/player", as: :player
              end
            end
          end
        end
      end
      json.away_team do
        json.extract! game.away_fantasy_team, :id, :name
        json.fantasy_starts do
          game.away_fantasy_team.fantasy_starts.group_by(&:week).each do |week, starts|
            json.set! week do
              json.array! starts.sort_by { |start| order.index(start.position) } do |start|
                json.extract! start, :id, :week, :position, :points
                json.player start.player, partial: "players/player", as: :player
              end
            end
          end
        end
      end
    end
  end

  json.owner @fantasy_team.owner, partial: "owners/owner", as: :owner

  json.purchases do
    json.array! @fantasy_team.purchases.order(price: :desc) do |purchase|
      json.extract! purchase, :id, :price, :position, :year

      json.player do
        json.extract! purchase.player, :id, :name
      end
    end
  end
end
