require_relative "addition_helpers"

### NEW SEASON ###

# 1. create /lib/assets/year_raw_auction.csv based on the auction

# 2. run task get_auction_ids to create final auction file

# 3. check file for any unmatched or double matches players, and fix all the error rows

# 4. create /lib/assets/year_new_players.csv based on the auction rookies and new draftees that were unmatched

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
      year = 2019
      driver = driver_start(current_league_url)

      if Owner.changed_on_web?(driver, current_league_url)
        raise "Detected a new owner!"
      end
      puts "check_owners passed"

      insert_new_teams(driver, current_league_url, year)
      "insert_new_teams passed"
      insert_new_players(year)
      "insert_new players passed"
      insert_auction(year)
      "insert_auction passed"
      # refresh all season stats or just new players?

      "season has begun!"
    rescue
      raise "error executing data gathering tasks"
    end
  end

  desc "add a new regular season week"
  task new_reg_week: :environment do
    begin
      year = 2019
      week = 13
      current_league_url = "https://fantasy.nfl.com/league/400302"
      driver = driver_start(current_league_url)

      verify_current_week(driver, current_league_url, week)
      puts "verify_current_week passed"
      check_owners(driver, current_league_url)
      puts "check_owners passed"
      update_teams(driver, current_league_url, year)
      puts "update_teams passed"
      get_regular_season_fantasy_games(driver, current_league_url, year, week)
      puts "get_regular_season_fantasy_games passed"
      find_and_create_unknown_players_regular(driver, current_league_url, week)
      puts "find_and_create_unknown_players_regular passed"
      get_fantasy_starts_regular(driver, current_league_url, year, week)
      puts "get_fantasy_starts passed"
      # mega update of all season_stats for every player in the db

    rescue
      raise "error adding a new league week"
    end
  end

  desc "add a new playoff week"
  task new_playoff_week: :environment do
    begin
      year = 2019
      week = 16
      current_league_url = "https://fantasy.nfl.com/league/400302"
      driver = driver_start(current_league_url)

      check_owners(driver, current_league_url)
      puts "check_owners passed"
      update_teams(driver, current_league_url, year)
      puts "update_teams passed"
      get_playoff_fantasy_games(driver, current_league_url, year, week)
      puts "get_playoff_fantasy_games passed"
      find_and_create_unknown_players_playoffs(driver, current_league_url, week)
      puts "find_and_create_unknown_players_playoffs passed"
      get_fantasy_starts_playoffs(driver, current_league_url, year, week)
      puts "get_fantasy_starts passed"
      # mega update of all season_stats for every player in the db

    rescue
      raise "error adding a new league week"
    end
  end

  desc "mega stat update"
  task stat_update: :environment do
    begin
      begin
        ActiveRecord::Base.transaction do
          Player.update_all_season_stats
        end
      end
      begin
        ActiveRecord::Base.transaction do
          SeasonStat.set_all_season_points
        end
      end
      begin
        ActiveRecord::Base.transaction do
          SeasonStat.set_all_experience
        end
      end
      begin
        ActiveRecord::Base.transaction do
          SeasonStat.set_all_ranks
        end
      end
    rescue
      raise "error updating player stats"
    end
    puts "DONE WITH MEGA STAT UPDATE"
  end
end
