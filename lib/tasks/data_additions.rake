require "nokogiri"
require "selenium-webdriver"
require "open-uri"
require "csv"
require "uri"

namespace :data_additions do
  desc "start up season"
  task season_start: :environment do
    begin
      current_league_url = "https://fantasy.nfl.com/league/400302"
      driver = driver_start(current_league_url)
      check_owners(driver, current_league_url)
      insert_new_teams(driver, current_league_url)
    rescue
      # could rollback here
      raise "error executing data gathering tasks"
    end
  end

  desc "potential player id matches for auction"
  task get_auction_ids: :environment do
    begin
      year = 2019

      final_file = "#{Rails.root}/lib/assets/#{year}_final_auction.csv"
      CSV.open(final_file, "w+") do |writer|
        raw_file = "#{year}_raw_auction"
        CSV.foreach("#{Rails.root}/lib/assets/#{raw_file}.csv", :headers => true) do |row|
          owner_name = row["owner_name"]
          price = row["price"]
          player_name = row["player_name"]

          potential_id_matches = Player.find_name_match((year - 1), player_name)
          message = "TooMany:#{potential_id_matches.join(":")}"
          if potential_id_matches.length == 0
            message = "NotFound"
          elsif potential_id_matches.length == 1
            message = potential_id_matches[0]
          end
          writer << [owner_name, price, player_name, message]
        end
      end
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

def insert_new_teams(driver, current_league_url)
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
        FantasyTeam.create!(owner: owner, year: Date.today.year, name: v)
      end
    end

    puts "New teams inserted... proceeding..."
  end
end
