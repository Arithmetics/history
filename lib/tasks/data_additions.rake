require_relative "firefox_driver"

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
      # current_league_url = "https://fantasy.nfl.com/league/400302"
      year = 2020
      # driver = driver_start(current_league_url)
      # # move
      # Owner.find_by(name: "Jeremy").update_attributes(name: "Jerms")
      # Owner.find_by(name: "jordan").update_attributes(name: "Jordan")
      # # move
      # Owner.changed_on_web?(driver, current_league_url)
      # FantasyTeam.create_all_teams_on_web(driver, current_league_url, year)
      # ScheduledFantasyGame.get_year_schedule_from_web(driver, current_league_url, year)
      # Player.insert_new_players_from_file("#{Rails.root}/lib/assets/#{year}_new_players.csv")
      # new_player = Player.new(name: "James Robinson", birthdate: "1998-08-09", nfl_URL_name: "james-robinson-3", picture_id: "lxzbao36eeratekmnxeb")
      # new_player.save!

      # Purchase.insert_auction("#{Rails.root}/lib/assets/#{year}_final_auction.csv", year)
      # Ranking.insert_rankings_from_file("#{Rails.root}/lib/assets/#{year}_preseason_rankings.csv")
      # Player.update_all_season_stats
      # SeasonStat.calculate_all_dependent_columns
      puts "season has begun!"
    rescue
      raise "error executing data gathering tasks"
    end
  end

  desc "add a new regular season week"
  task new_reg_week: :environment do
    begin
      year = 2020
      week = 7
      current_league_url = "https://fantasy.nfl.com/league/400302"
      driver = driver_start(current_league_url)
      # verify_current_week(driver, current_league_url, week)
      # comment out if no new players
      Player.insert_new_players_from_file("#{Rails.root}/lib/assets/#{year}_week_#{week}_new_players.csv")
      Player.find_and_print_unknown_players_regular(driver, current_league_url, week)
      # will stop here if theres new players
      Owner.changed_on_web?(driver, current_league_url)
      FantasyTeam.update_team_names_and_pictures_from_web(driver, current_league_url, year)
      FantasyGame.get_regular_season_fantasy_games(driver, current_league_url, year, week)

      FantasyStart.get_starts_from_web_regular(driver, current_league_url, year, week)
      Player.update_all_season_stats
      SeasonStat.calculate_all_dependent_columns
      ScheduledFantasyGame.remove_last_played_week
      PlayoffOdd.save_current_playoff_odds(week, 1000)
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
      Owner.check_if_changed_on_web(driver, current_league_url)
      FantasyTeam.update_team_names_and_pictures_from_web(driver, current_league_url, year)
      FantasyGame.get_playoff_fantasy_games(driver, current_league_url, year, week)
      Player.find_and_print_unknown_players_playoffs(driver, current_league_url, week)
      FantasyStart.get_starts_from_web_playoffs(driver, current_league_url, year, week)
      Player.update_all_season_stats
      SeasonStat.calculate_all_dependent_columns
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

  desc "temp test"
  task debug_run: :environment do
    FantasyTeam.all.each do |team|
      puts "#{team.owner.name} - #{team.name} - #{team.breakdown_wins_by_week(4)}"
    end
  end

  desc "2020_week_4_fix"
  task fix_2020_4: :environment do
    ActiveRecord::Base.transaction do
      filepath = "#{Rails.root}/lib/assets/birthday_url_fix.csv"
      CSV.foreach(filepath, :headers => true) do |row|
        player_name = row["name"]
        player_id = row["profile_id"].to_i
        birthdate = Date.strptime(row["birthdate"], "%m/%d/%Y")
        picture_id = row["picture_id"]
        nfl_URL_name = row["nfl_URL_name"]

        player = Player.find(player_id)
        player.birthdate = birthdate
        player.nfl_URL_name = nfl_URL_name
        puts "Player updated: #{player.name}"
        player.save!
      end
    end
    puts "2020_week_4_fix passed"
  end
end
