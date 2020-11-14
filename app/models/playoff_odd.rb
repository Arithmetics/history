class PlayoffOdd < ApplicationRecord
  belongs_to :fantasy_team
  validates_inclusion_of :category, :in => ["make_playoffs", "get_bye", "win_championship"]

  def self.save_current_playoff_odds(current_week, num_sims)
    puts "Starting playoff odds sim for week #{current_week}"
    run_num = 0
    live_fantasy_teams = FantasyTeam.includes(:away_fantasy_games, :home_fantasy_games).where(year: FantasyTeam.maximum(:year))

    team_id_to_wins_template = live_fantasy_teams.reduce({}) { |acc, x| acc.merge(x[:id] => x.season_wins) }
    team_id_to_score_template = live_fantasy_teams.reduce({}) { |acc, x| acc.merge(x[:id] => x.season_points) }

    remaining_regular_season_games = ScheduledFantasyGame.includes(:home_fantasy_team, :away_fantasy_team).all

    # times made playoffs when winning in the current week
    times_made_playoffs_as_winner = team_id_to_wins_template.clone.map { |k, v| [k, 0] }.to_h
    times_get_bye_as_winner = times_made_playoffs_as_winner.clone
    times_win_championship_as_winner = times_made_playoffs_as_winner.clone

    # times made playoffs when losing in the current week
    times_made_playoffs_as_loser = team_id_to_wins_template.clone.map { |k, v| [k, 0] }.to_h
    times_get_bye_as_loser = times_made_playoffs_as_loser.clone
    times_win_championship_as_loser = times_made_playoffs_as_loser.clone

    num_sims.times do
      run_num += 1
      puts "Running odds sim #{run_num}/#{num_sims}"
      team_id_to_wins = team_id_to_wins_template.clone
      team_id_to_score = team_id_to_score_template.clone
      team_id_to_did_win_first_week = team_id_to_wins_template.clone.map { |k, v| [k, false] }.to_h

      remaining_regular_season_games.each_with_index do |game, index|
        sim_away_score = game.away_fantasy_team.generate_random_score
        sim_home_score = game.home_fantasy_team.generate_random_score
        if sim_away_score > sim_home_score
          team_id_to_wins[game.away_fantasy_team.id] += 1
          if index === 0 #first simed game
            team_id_to_did_win_first_week[game.away_fantasy_team.id] = true
          end
        else
          team_id_to_wins[game.home_fantasy_team.id] += 1
          if index === 0 #first simed game
            team_id_to_did_win_first_week[game.home_fantasy_team.id] = true
          end
        end
        team_id_to_score[game.away_fantasy_team.id] += sim_away_score
        team_id_to_score[game.home_fantasy_team.id] += sim_home_score
      end

      rankings = team_id_to_wins.keys
      rankings.sort_by! { |id| [team_id_to_wins[id], team_id_to_score[id]] }.reverse

      rankings[6..11].each do |team_id|
        did_win_first_week = team_id_to_did_win_first_week[team_id]
        if did_win_first_week
          times_made_playoffs_as_winner[team_id] += 1
        else
          times_made_playoffs_as_loser[team_id] += 1
        end
      end

      rankings[10..11].each do |team_id|
        did_win_first_week = team_id_to_did_win_first_week[team_id]

        if did_win_first_week
          times_get_bye_as_winner[team_id] += 1
        else
          times_get_bye_as_loser[team_id] += 1
        end
      end

      championship_team_id = self.get_champion_from_sim(rankings[6..11])

      did_champ_win_first_week = team_id_to_did_win_first_week[championship_team_id]
      if did_champ_win_first_week
        times_win_championship_as_winner[championship_team_id] += 1
      else
        times_win_championship_as_loser[championship_team_id] += 1
      end
    end

    total_times_made_playoffs = {}
    times_made_playoffs_as_winner.each do |k, v|
      total_times_made_playoffs[k] = times_made_playoffs_as_winner[k] + times_made_playoffs_as_loser[k]
    end

    total_times_get_bye = {}
    times_get_bye_as_winner.each do |k, v|
      total_times_get_bye[k] = times_get_bye_as_winner[k] + times_get_bye_as_loser[k]
    end

    total_times_win_championship = {}
    times_win_championship_as_winner.each do |k, v|
      total_times_win_championship[k] = times_win_championship_as_winner[k] + times_win_championship_as_loser[k]
    end

    begin
      ActiveRecord::Base.transaction do
        save_odds("make_playoffs", num_sims, total_times_made_playoffs, current_week)
        save_odds("get_bye", num_sims, total_times_get_bye, current_week)
        save_odds("win_championship", num_sims, total_times_win_championship, current_week)
      end
    end
  end

  def self.get_champion_from_sim(ranked_team_ids)
    # index 5 = one seed
    # index 4 = two seed
    # index 3 = three seed
    # index 2 = four seed
    # index 1 = five seed
    # index 0 = six seed
    wc_winner_one_id = 0
    wc_winner_two_id = 0

    sf_winner_one_id = 0
    sf_winner_two_id = 0
    test = FantasyTeam.find(ranked_team_ids[0])

    if FantasyTeam.find(ranked_team_ids[0]).generate_random_score() > FantasyTeam.find(ranked_team_ids[3]).generate_random_score()
      wc_winner_one_id = ranked_team_ids[0]
    else
      wc_winner_one_id = ranked_team_ids[3]
    end

    if FantasyTeam.find(ranked_team_ids[1]).generate_random_score() > FantasyTeam.find(ranked_team_ids[2]).generate_random_score()
      wc_winner_two_id = ranked_team_ids[1]
    else
      wc_winner_two_id = ranked_team_ids[2]
    end

    if FantasyTeam.find(wc_winner_one_id).generate_random_score() > FantasyTeam.find(ranked_team_ids[4]).generate_random_score()
      sc_winner_one_id = wc_winner_one_id
    else
      sc_winner_one_id = ranked_team_ids[4]
    end

    if FantasyTeam.find(wc_winner_two_id).generate_random_score() > FantasyTeam.find(ranked_team_ids[5]).generate_random_score()
      sc_winner_two_id = wc_winner_two_id
    else
      sc_winner_two_id = ranked_team_ids[5]
    end

    if FantasyTeam.find(sc_winner_two_id).generate_random_score() > FantasyTeam.find(sc_winner_one_id).generate_random_score()
      return sc_winner_two_id
    end
    return sc_winner_one_id
  end

  def self.save_odds(category_of_odd, num_sims, times_made_playoffs, current_week)
    times_made_playoffs.each do |team_id, times|
      new_odds = self.new()
      new_odds.fantasy_team_id = team_id
      new_odds.year = FantasyTeam.maximum(:year)
      new_odds.week = current_week
      new_odds.category = category_of_odd
      new_odds.odds = (times.to_f / num_sims.to_f).round(3)
      new_odds.save!
    end
  end
  ##
end
