require "nokogiri"
require "selenium-webdriver"
require "open-uri"
require "csv"
require "uri"

### NEW SEASON ###

# 1. create /lib/assets/year_raw_auction.csv based on the auction

# 2. run get_potential_ids to get final auction file

# 3. check file for any unmatched or double matches players, and fix all the error rows

# 4. create /lib/assets/year_new_players.csv based on the auction rookies and new drafts that were unmatched

# 5. run season_start

namespace :data_additions do
  desc "start up season"
  task season_start: :environment do
    begin
      current_league_url = "https://fantasy.nfl.com/league/400302"
      year = 2019
      driver = driver_start(current_league_url)
      check_owners(driver, current_league_url)
      insert_new_teams(driver, current_league_url, year)
      insert_new_players(year)
      insert_auction(year)
    rescue
      raise "error executing data gathering tasks"
    end
  end

  desc "add a new regular season week"
  task new_reg_week: :environment do
    begin
      year = 2019
      week = 14
      current_league_url = "https://fantasy.nfl.com/league/400302"
      driver = driver_start(current_league_url)
      verify_current_week(driver, current_league_url, week)
      # in progress here
    rescue
      raise "error adding a new league week"
    end
  end

  desc "potential player id matches for auction"
  task get_auction_ids: :environment do
    begin
      year = 2019
      get_potential_ids(year)
    rescue
      raise "error getting id matches"
    end
  end
end

def driver_start(current_league_url)
  driver = Selenium::WebDriver.for :firefox
  driver.navigate.to "https://www.nfl.com/login?s=fantasy&returnTo=http%3A%2F%2Ffantasy.nfl.com%2Fleague%2F400302"
  sleep(1)
  username = driver.find_element(id: "fanProfileEmailUsername")
  password = driver.find_element(id: "fanProfilePassword")
  submit = driver.find_element(xpath: "/html/body/div[1]/div/div/div[2]/div[1]/div/div/div[2]/main/div/div[2]/div[2]/form/div[3]/button")
  sleep(1)
  username.send_keys("brock.m.tillotson@gmail.com")
  password.send_keys(ENV["NFL_PASSWORD"])
  submit.click()
  sleep(2)
  driver.navigate.to current_league_url
  return driver
end

def check_owners(driver, current_league_url)
  driver.navigate.to "#{current_league_url}/owners"

  doc = Nokogiri::HTML(driver.page_source)
  page_owners = doc.css(".userName")
  owner_count = 0
  page_owners.each do |owner|
    x = Owner.find_by_name(owner.text)
    puts "Found #{x.name}"
    if x != nil
      owner_count += 1
    end
  end

  if owner_count != 12
    raise "Not enough matching owners!, stopping task"
  end

  puts "Owners look good.... proceeding..."
end

def get_potential_ids(year)
  final_file = "#{Rails.root}/lib/assets/#{year}_final_auction.csv"
  CSV.open(final_file, "w+") do |writer|
    raw_file = "#{year}_raw_auction"
    CSV.foreach("#{Rails.root}/lib/assets/#{raw_file}.csv", :headers => true) do |row|
      owner_name = row["owner_name"]
      price = row["price"]
      player_name = row["player_name"]
      position = row["position"]

      potential_id_matches = Player.find_name_match((year - 1), player_name)
      message = "TooMany:#{potential_id_matches.join(":")}"
      if potential_id_matches.length == 0
        message = "NotFound"
      elsif potential_id_matches.length == 1
        message = potential_id_matches[0]
      end
      writer << ["owner_name", "price", "position", "player_name", "player_id"]
      writer << [owner_name, price, position, player_name, message]
    end
  end
end

def insert_new_teams(driver, current_league_url, year)
  driver.navigate.to "#{current_league_url}/owners"

  doc = Nokogiri::HTML(driver.page_source)
  owner_table = doc.css("#leagueOwners")
  rows = owner_table.css("tbody").css("tr")
  team_key = {}
  rows.each do |row|
    owner = row.css(".userName").text
    team = row.css(".teamName").text
    team_key[owner] = team
  end

  begin
    ActiveRecord::Base.transaction do
      team_key.each do |k, v|
        owner = Owner.find_by_name(k)
        if owner == nil
          raise "Missing owner: #{k}!"
        end
        FantasyTeam.create!(owner: owner, year: year, name: v)
      end
    end

    puts "New teams inserted... proceeding..."
  end
end

def insert_new_players(year)
  filepath = "#{Rails.root}/lib/assets/#{year}_new_players.csv"
  Player.insert_new_players(filepath)
  puts "New players inserted for #{year}... proceeding..."
end

def insert_auction(year)
  filepath = "#{Rails.root}/lib/assets/#{year}_final_auction.csv"
  Purchase.insert_auction(filepath, year)
  puts "Auction for #{year} inserted... proceeding..."
end

def verify_current_week(driver, current_league_url, week)
  driver.navigate.to "#{current_league_url}?standingsTab=standings&standingsType=overall"
  sleep(2)
  doc = Nokogiri::HTML(driver.page_source)
  ts = doc.css(".teamRecord")
  team_record = doc.css(".teamRecord")[6].text()
  games = team_record.split("-")
  weeks_played = 0
  games.each do |game|
    weeks_played += game.to_i
  end

  if weeks_played != (week - 1)
    throw("Something may be wrong with your set week, please check or override verify_current_week \n weeks played: #{weeks_played}, set week #{week}")
  end
  return nil
end
