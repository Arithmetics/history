class PlayoffOdd < ApplicationRecord
  belongs_to :fantasy_team
  validates_inclusion_of :type, :in => ["make_playoffs", "get_bye", "win_champion"]

  def self.save_current_playoff_odds(current_week, num_sims)
    live_fantasy_teams = FantasyTeam.includes(:away_fantasy_games, :home_fantasy_games).where(year: FantasyTeam.maximum(:year))

    team_id_to_wins_template = live_fantasy_teams.reduce({}) { |acc, x| acc.merge(x[:id] => x.season_wins) }
    team_id_to_score_template = live_fantasy_teams.reduce({}) { |acc, x| acc.merge(x[:id] => x.season_points) }

    remaining_regular_season_games = ScheduledFantasyGame.includes(:home_fantasy_team, :away_fantasy_team).all

    times_made_playoffs = team_id_to_wins_template.clone.map { |k, v| [k, 0] }.to_h

    num_sims.times do
      team_id_to_wins = team_id_to_wins_template.clone
      team_id_to_score = team_id_to_score_template.clone

      remaining_regular_season_games.each do |game|
        sim_away_score = game.away_fantasy_team.generate_random_score
        sim_home_score = game.home_fantasy_team.generate_random_score
        if sim_away_score > sim_home_score
          team_id_to_wins[game.away_fantasy_team.id] += 1
          team_id_to_score[game.away_fantasy_team.id] += sim_away_score
        else
          team_id_to_wins[game.home_fantasy_team.id] += 1
          team_id_to_score[game.home_fantasy_team.id] += sim_home_score
        end
      end

      rankings = team_id_to_wins.keys
      rankings.sort_by! { |id| [team_id_to_wins[id], team_id_to_score[id]] }.reverse
      rankings[6..11].each { |team_id| times_made_playoffs[team_id] += 1 }
    end
    insert_db_odds(num_sims, times_made_playoffs, current_week)
  end

  def self.insert_db_odds(num_sims, times_made_playoffs, current_week)
    begin
      ActiveRecord::Base.transaction do
        times_made_playoffs.each do |team_id, times|
          new_odds = self.new()
          new_odds.fantasy_team_id = team_id
          new_odds.week = current_week
          new_odds.type = "make_playoffs"
          new_odds.odds = (times.to_f / num_sims.to_f).round(3)
          new_odds.save!
        end
      end
    end
  end
  ##
end
