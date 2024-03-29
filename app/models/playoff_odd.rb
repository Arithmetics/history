class PlayoffOdd < ApplicationRecord
  belongs_to :fantasy_team
  validates_inclusion_of :category, :in => ["make_playoffs", "get_bye", "win_championship"]

  def self.save_current_playoff_odds(completed_week, num_sims)
    puts "Starting playoff odds sim for week #{completed_week}"
    run_num = 0
    current_year = FantasyTeam.maximum(:year)
    live_fantasy_teams = FantasyTeam.includes(:away_fantasy_games, :home_fantasy_games).where(year: current_year)

    score_possibility_lookup_table = self.get_score_possibility_lookup_table(current_year, completed_week)

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

    team_id_to_times_win_first_week = team_id_to_wins_template.clone.map { |k, v| [k, 0] }.to_h



    num_sims.times do
      run_num += 1
      puts "Running odds sim #{run_num}/#{num_sims}"
      team_id_to_wins = team_id_to_wins_template.clone
      team_id_to_score = team_id_to_score_template.clone
      team_id_to_did_win_first_week = team_id_to_wins_template.clone.map { |k, v| [k, false] }.to_h

      first_week_num = 0
      remaining_regular_season_games.each_with_index do |game, index|
        if index === 0
          first_week_num = game.week
        end
        sim_away_score = game.away_fantasy_team.generate_random_score(score_possibility_lookup_table)
        sim_home_score = game.home_fantasy_team.generate_random_score(score_possibility_lookup_table)
        if sim_away_score > sim_home_score
          team_id_to_wins[game.away_fantasy_team.id] += 1
          if first_week_num === game.week #first simed game
            team_id_to_did_win_first_week[game.away_fantasy_team.id] = true
            team_id_to_times_win_first_week[game.away_fantasy_team.id] += 1
          end
        else
          team_id_to_wins[game.home_fantasy_team.id] += 1
          if first_week_num === game.week #first simed game
            team_id_to_did_win_first_week[game.home_fantasy_team.id] = true
            team_id_to_times_win_first_week[game.home_fantasy_team.id] += 1
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

      championship_team_id = self.get_champion_from_sim(rankings[6..11], score_possibility_lookup_table)

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
        save_odds("make_playoffs", num_sims, total_times_made_playoffs, times_made_playoffs_as_winner, times_made_playoffs_as_loser, team_id_to_times_win_first_week, completed_week)
        save_odds("get_bye", num_sims, total_times_get_bye, times_get_bye_as_winner, times_get_bye_as_loser, team_id_to_times_win_first_week, completed_week)
        save_odds("win_championship", num_sims, total_times_win_championship, times_win_championship_as_winner, times_win_championship_as_loser, team_id_to_times_win_first_week, completed_week)
      end
    end
  end

  def self.get_champion_from_sim(ranked_team_ids, score_possibility_lookup_table)
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

    if FantasyTeam.find(ranked_team_ids[0]).generate_random_score(score_possibility_lookup_table) > FantasyTeam.find(ranked_team_ids[3]).generate_random_score(score_possibility_lookup_table)
      wc_winner_one_id = ranked_team_ids[0]
    else
      wc_winner_one_id = ranked_team_ids[3]
    end

    if FantasyTeam.find(ranked_team_ids[1]).generate_random_score(score_possibility_lookup_table) > FantasyTeam.find(ranked_team_ids[2]).generate_random_score(score_possibility_lookup_table)
      wc_winner_two_id = ranked_team_ids[1]
    else
      wc_winner_two_id = ranked_team_ids[2]
    end

    if FantasyTeam.find(wc_winner_one_id).generate_random_score(score_possibility_lookup_table) > FantasyTeam.find(ranked_team_ids[4]).generate_random_score(score_possibility_lookup_table)
      sc_winner_one_id = wc_winner_one_id
    else
      sc_winner_one_id = ranked_team_ids[4]
    end

    if FantasyTeam.find(wc_winner_two_id).generate_random_score(score_possibility_lookup_table) > FantasyTeam.find(ranked_team_ids[5]).generate_random_score(score_possibility_lookup_table)
      sc_winner_two_id = wc_winner_two_id
    else
      sc_winner_two_id = ranked_team_ids[5]
    end

    if FantasyTeam.find(sc_winner_two_id).generate_random_score(score_possibility_lookup_table) > FantasyTeam.find(sc_winner_one_id).generate_random_score(score_possibility_lookup_table)
      return sc_winner_two_id
    end
    return sc_winner_one_id
  end

  def self.save_odds(category_of_odd, num_sims, total_times, total_times_as_winner, total_times_as_loser, team_id_to_times_win_first_week, current_week)
    total_times.each do |team_id, times|
      new_odds = self.new()
      new_odds.fantasy_team_id = team_id
      new_odds.year = FantasyTeam.maximum(:year)
      new_odds.week = current_week
      new_odds.category = category_of_odd
      new_odds.odds = (times.to_f / num_sims.to_f).round(3)
      new_odds.odds_with_win = ((total_times_as_winner[team_id]).to_f / team_id_to_times_win_first_week[team_id]).round(3)
      new_odds.odds_with_loss = ((total_times_as_loser[team_id]).to_f / (num_sims.to_f - team_id_to_times_win_first_week[team_id])).round(3)
      new_odds.save!
    end
  end

  def self.get_score_possibility_lookup_table(current_year, completed_week)
    lookup = {}
    previous_fantasy_teams = FantasyTeam.where("year < ?", current_year)
    previous_fantasy_teams.each do |team|

      starting_away_games = team.away_fantasy_games.filter {|game| game.week <= completed_week}
      remaining_away_games = team.away_fantasy_games.filter {|game| game.week > completed_week}

      starting_home_games = team.home_fantasy_games.filter {|game| game.week <= completed_week}
      remaining_home_games = team.home_fantasy_games.filter {|game| game.week > completed_week}

      starting_grades = starting_away_games.map {|g| g.away_grade}.concat(starting_home_games.map {|g| g.home_grade})

      remaining_week_grades = remaining_away_games.map {|g| g.away_grade}.concat(remaining_home_games.map {|g| g.home_grade})
      

      starting_grades_as_numbers = starting_grades.map {|grade| FantasyGame.convert_letter_to_number(grade)}
      remaining_week_grades_as_numbers = remaining_week_grades.map {|grade| FantasyGame.convert_letter_to_number(grade)}

      average_starting_grade_as_number = starting_grades_as_numbers.sum(0.0) / starting_grades_as_numbers.size
      
      average_starting_grade = FantasyGame.convert_to_letter_grade(average_starting_grade_as_number)

      if (lookup[average_starting_grade] == nil) 
        lookup[average_starting_grade] = []
      end

      lookup[average_starting_grade].concat(remaining_week_grades_as_numbers)
    end
    return lookup
  end
  ##
end
