require_relative "firefox_driver"

### NEW SEASON ###

# 1. add new players drafted in ui

# 2. create /lib/assets/year_raw_auction.csv based on the auction

# 3. run task get_auction_ids to create final auction file

# 3. check file for any unmatched or double matches players, and fix all the error rows


# 5. run season_start

### NEW WEEK ###

# 1. run new_reg_week

### NEW PLAYOFF WEEK ###

# 1. run new_playoff_week

namespace :data_additions do
  desc "potential player id matches for auction"
  task get_auction_ids: :environment do
    begin
      year = 2019
      Purchase.convert_raw_to_final(year)
    rescue
      raise "error getting id matches"
    end
  end

  desc "start up season"
  task season_start: :environment do
    begin
      current_league_url = "https://fantasy.nfl.com/league/400302"
      year = 2021
      driver = driver_start(current_league_url)

      Owner.changed_on_web?(driver, current_league_url)
      FantasyTeam.create_all_teams_on_web(driver, current_league_url, year)
      ScheduledFantasyGame.get_year_schedule_from_web(driver, current_league_url, year)

      Purchase.insert_auction("#{Rails.root}/lib/assets/#{year}_final_auction.csv", year)
      Ranking.insert_rankings_from_file("#{Rails.root}/lib/assets/#{year}_preseason_rankings.csv")
      Player.update_all_season_stats
      SeasonStat.calculate_all_dependent_columns
      puts "season has begun!"
    rescue
      raise "error executing data gathering tasks"
    end
  end

  desc "add a new regular season week"
  task new_reg_week: :environment do
    begin
      year = 2021
      week = 11 # the week that just completed
      current_league_url = "https://fantasy.nfl.com/league/400302"
      driver = driver_start(current_league_url)
      verify_current_week(driver, current_league_url, week)
      Owner.changed_on_web?(driver, current_league_url)
      Player.find_and_print_unknown_players_regular(driver, current_league_url, week)
      # will stop here if theres new players
      FantasyTeam.update_team_names_and_pictures_from_web(driver, current_league_url, year)
      FantasyGame.get_regular_season_fantasy_games(driver, current_league_url, year, week)
      FantasyStart.get_starts_from_web_regular(driver, current_league_url, year, week)
      # imports done
      # Player.update_all_season_stats
      # SeasonStat.calculate_all_dependent_columns
      # FantasyGame.grade_season_games(year)
      # ScheduledFantasyGame.remove_last_played_week
      # PlayoffOdd.save_current_playoff_odds(week, 1000)
    rescue
      raise "error adding a new league week"
    end
  end

  desc "add a new playoff week"
  task new_playoff_week: :environment do
    begin
      year = 2021
      week = 16 # the week that just completed
      current_league_url = "https://fantasy.nfl.com/league/400302"
      driver = driver_start(current_league_url)
      # verify_current_week(driver, current_league_url, week)
      Owner.changed_on_web?(driver, current_league_url)
      Player.find_and_print_unknown_players_playoffs(driver, current_league_url, week)
      #
      FantasyTeam.update_team_names_and_pictures_from_web(driver, current_league_url, year)
      FantasyGame.get_playoff_fantasy_games(driver, current_league_url, year, week)
      FantasyStart.get_starts_from_web_playoffs(driver, current_league_url, year, week)
      #imports done
      Player.update_all_season_stats
      SeasonStat.calculate_all_dependent_columns
      FantasyGame.grade_season_games(year)
      ScheduledFantasyGame.remove_last_played_week
      PlayoffOdd.save_current_playoff_odds(week, 1000)
      puts "DONE NICE"
    rescue
      raise "error adding a new league week"
    end
  end

  desc "mega stat update"
  task stat_update: :environment do
    begin
      Player.update_all_season_stats
      SeasonStat.calculate_all_dependent_columns
    rescue
      raise "error updating player stats"
    end
    puts "DONE WITH MEGA STAT UPDATE"
  end

  desc "debug run"
  task debug_run: :environment do
    x = FantasyTeam.find(112).position_category_stats
    puts x
  end
end
