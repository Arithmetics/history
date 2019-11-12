#holy crab this needs a refactor, not sure if i will use again though

namespace :interesting do
  desc "Finds starts of non qbs in the op slot and print stats"
  task find_non_qb_op: :environment do
    won_games = []
    lost_games = []
    games = FantasyGame.all

    owners = {}

    def get_position_away(x)
      start = x.away_fantasy_team.fantasy_starts.where("year = ? AND week = ? AND position = ?", x.year, x.week, "Q/R/W/T").first
      if start != nil
        position = start.player.season_stats.where("year = ?", x.year).first.position
        if position != "QB"
          puts start.player.name
        end
        return position
      end
      return "QB"
    end

    def get_position_home(x)
      start = x.home_fantasy_team.fantasy_starts.where("year = ? AND week = ? AND position = ?", x.year, x.week, "Q/R/W/T").first
      if start != nil
        position = start.player.season_stats.where("year = ?", x.year).first.position
        if position != "QB"
          puts start.player.name
        end
        return position
      end
      return "QB"
    end

    games.each do |game|
      if (get_position_home(game) != "QB")
        if (game.home_score > game.away_score)
          won_games.push(game)
          if !owners[game.home_fantasy_team.owner.name]
            owners[game.home_fantasy_team.owner.name] = [1, 0]
          else
            owners[game.home_fantasy_team.owner.name][0] += 1
          end
        else
          lost_games.push(game)
          if !owners[game.home_fantasy_team.owner.name]
            owners[game.home_fantasy_team.owner.name] = [0, 1]
          else
            owners[game.home_fantasy_team.owner.name][1] += 1
          end
        end
      elsif (get_position_away(game) != "QB")
        if (game.away_score > game.home_score)
          won_games.push(game)
          if !owners[game.away_fantasy_team.owner.name]
            owners[game.away_fantasy_team.owner.name] = [1, 0]
          else
            owners[game.away_fantasy_team.owner.name][0] += 1
          end
        else
          lost_games.push(game)
          if !owners[game.home_fantasy_team.owner.name]
            owners[game.home_fantasy_team.owner.name] = [0, 1]
          else
            owners[game.home_fantasy_team.owner.name][1] += 1
          end
        end
      end
    end

    puts owners
  end
end
