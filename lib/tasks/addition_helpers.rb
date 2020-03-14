require "nokogiri"
require "selenium-webdriver"
require "open-uri"
require "csv"
require "uri"

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

def insert_new_teams(driver, current_league_url, year)
  team_map = get_current_teams(driver, current_league_url)
  begin
    ActiveRecord::Base.transaction do
      team_map.each do |k, v|
        owner = Owner.find_by_name(k)
        if owner == nil
          raise "Missing owner: #{k}!"
        end
        puts "Creating new team: #{v} for owner #{owner.name}"
        FantasyTeam.create!(owner: owner, year: year, name: v)
      end
    end

    puts "New teams inserted... proceeding..."
  end
end

def update_teams(driver, current_league_url, year)
  team_map = get_current_teams(driver, current_league_url)

  begin
    ActiveRecord::Base.transaction do
      team_map.each do |k, v|
        owner = Owner.find_by_name(k)
        if owner == nil
          raise "Missing owner: #{k}!"
        end
        fantasy_team = FantasyTeam.find_by(year: year, name: v)
        if fantasy_team == nil
          fantasy_team = FantasyTeam.find_by(year: year, owner: owner)
          if fantasy_team == nil
            raise "Missing fantasy team: year: #{year}, owner: #{owner.name}"
          end
          puts "Team: #{fantasy_team.name} is getting a new name: #{v}"
          fantasy_team.update!(name: v)
        end
      end
    end

    puts "Team updates complete... proceeding..."
  end
end

def get_current_teams(driver, current_league_url)
  driver.navigate.to "#{current_league_url}/owners"

  doc = Nokogiri::HTML(driver.page_source)
  owner_table = doc.css("#leagueOwners")
  rows = owner_table.css("tbody").css("tr")
  team_map = {}
  rows.each do |row|
    owner = row.css(".userName").text
    team = row.css(".teamName").text
    team_map[owner] = team
  end
  return team_map
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

def verify_current_week(driver, current_league_url, week)
  if week < 1 || week > 13
    throw("supplied week, #{week}, is not a regular season week")
  end
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

def get_regular_season_fantasy_games(driver, current_league_url, year, week)
  team_ids = *(1..12)
  get_fantasy_games(driver, current_league_url, year, week, team_ids)
end

def get_playoff_fantasy_games(driver, current_league_url, year, week)
  team_ids = determine_playoff_week_teams(driver, current_league_url, week)
  get_fantasy_games(driver, current_league_url, year, week, team_ids)
end

def get_fantasy_games(driver, current_league_url, year, week, team_numbers)
  begin
    ActiveRecord::Base.transaction do
      team_numbers.each do |team_number|
        driver.navigate.to "#{current_league_url}/team/#{team_number}/gamecenter?gameCenterTab=track&trackType=sbs&week=#{week}"
        sleep(2)
        doc = Nokogiri::HTML(driver.page_source)
        header = doc.css("#teamMatchupHeader")

        away_team_name = header.css(".teamWrap-1").css(".teamName").text
        away_team_score = header.css(".teamWrap-1").css(".teamTotal").text.to_f

        home_team_name = header.css(".teamWrap-2").css(".teamName").text
        home_team_score = header.css(".teamWrap-2").css(".teamTotal").text.to_f

        home_team_number = header.css(".teamWrap-2").css("a")[0]["href"].split("/").last.to_i

        team_numbers.delete(home_team_number)

        away_team = FantasyTeam.find_by(name: away_team_name, year: year)
        home_team = FantasyTeam.find_by(name: home_team_name, year: year)

        if away_team == nil
          raise "Cant find a match for team: #{away_team_name}"
        end
        if home_team == nil
          raise "Cant find a match for team: #{home_team_name}"
        end
        FantasyGame.create!(
          year: year,
          week: week,
          away_fantasy_team: away_team,
          away_score: away_team_score,
          home_fantasy_team: home_team,
          home_score: home_team_score,
        )
      end
    end

    puts "Week's Fantasy Games inserted... proceeding..."
  end
end

def find_and_create_unknown_players_regular(driver, current_league_url, week)
  team_ids = *(1..12)
  find_and_create_unknown_players(driver, current_league_url, week, team_ids)
end

def find_and_create_unknown_players_playoffs(driver, current_league_url, week)
  team_ids = determine_playoff_week_teams(driver, current_league_url, week)
  find_and_create_unknown_players(driver, current_league_url, week, team_ids)
end

def find_and_create_unknown_players(driver, current_league_url, week, team_numbers)
  playoff_week_teams = determine_playoff_week_teams(driver, current_league_url, week)

  weeks_player_ids = []

  team_numbers.each do |team_number|
    driver.navigate.to "#{current_league_url}/team/#{team_number}/gamecenter?gameCenterTab=track&trackType=sbs&week=#{week}"
    sleep(2)
    doc = Nokogiri::HTML(driver.page_source)
    box = doc.css("#teamMatchupBoxScore")
    left_roster = box.css(".teamWrap-1")
    all_player_links = left_roster.css(".playerNameFirstInitialLastName").css("a")

    all_player_links.each do |link|
      href = link["href"]
      id = href.split("=").last
      weeks_player_ids.push(id)
    end
  end

  unknown_ids = []

  weeks_player_ids.each do |id|
    player = Player.find_by(id: id)
    if player == nil
      unknown_ids.push(id)
    end
  end

  new_players = []

  unknown_ids.each do |id|
    new_players.push(scrape_unknown_player(driver, id))
  end

  begin
    ActiveRecord::Base.transaction do
      new_players.each do |player|
        puts "Saving new player: #{player.name}"
        player.save!
      end
    end

    puts "All new players were inserted... proceeding..."
  end
end

def scrape_unknown_player(driver, id)
  driver.navigate.to "http://www.nfl.com/player/mattryan/#{id}/profile"
  doc = Nokogiri::HTML(driver.page_source)
  new_player = Player.new
  new_player.id = id
  new_player.name = doc.css(".player-name").text.strip
  birthdate_string = get_birthday_string(doc)
  new_player.birthdate = Date.strptime(birthdate_string, "%m/%d/%Y")
  new_player.picture_id = doc.css(".player-photo").css("img")[0]["src"].split("/").last.gsub(".png", "")

  return new_player
end

def get_birthday_string(doc)
  all_p = doc.css(".player-info").css("p")
  if all_p.length == 5
    return doc.css(".player-info").css("p")[2].text.split(" ")[1]
  end
  return doc.css(".player-info").css("p")[3].text.split(" ")[1]
end

def get_fantasy_starts_regular(driver, current_league_url, year, week)
  team_ids = *(1..12)
  get_fantasy_starts(driver, current_league_url, year, week, team_ids)
end

def get_fantasy_starts_playoffs(driver, current_league_url, year, week)
  team_ids = determine_playoff_week_teams(driver, current_league_url, week)
  get_fantasy_starts(driver, current_league_url, year, week, team_ids)
end

def get_fantasy_starts(driver, current_league_url, year, week, team_numbers)
  new_fantasy_starts = []

  team_numbers.each do |team_number|
    driver.navigate.to "#{current_league_url}/team/#{team_number}/gamecenter?gameCenterTab=track&trackType=sbs&week=#{week}"
    sleep(2)
    doc = Nokogiri::HTML(driver.page_source)
    box = doc.css("#teamMatchupBoxScore")
    left_roster = box.css(".teamWrap-1")

    team_name = left_roster.css("h4").text
    fantasy_team = FantasyTeam.find_by(name: team_name, year: year)
    if fantasy_team == nil
      throw "Unknown fantasy team: #{team_name}"
    end

    starter_rows = left_roster.css("#tableWrap-1").css("tbody").css("tr")
    starter_rows.each do |row|
      new_start = get_start_from_row(row, fantasy_team, year, week)
      if new_start != nil
        new_fantasy_starts.push(new_start)
      end
    end

    bench_rows = left_roster.css(".tableWrapBN").css("tbody").css("tr")
    bench_rows.each do |row|
      new_start = get_start_from_row(row, fantasy_team, year, week)
      if new_start != nil
        new_fantasy_starts.push(new_start)
      end
    end
  end

  begin
    ActiveRecord::Base.transaction do
      new_fantasy_starts.each do |start|
        puts "Saving new start: #{start}"
        start.save!
      end
    end

    puts "All new fantasy starts were inserted... proceeding..."
  end
end

def get_start_from_row(row, fantasy_team, year, week)
  if row.css(".playerNameAndInfo").css("a").length > 0
    player_id = row.css(".playerNameAndInfo").css("a")[0]["href"].split("=").last.to_i

    position = row.css(".teamPosition").text
    fantasy_points = row.css(".playerTotal").text.to_f

    player = Player.find_by(id: player_id)

    if player == nil
      throw "Unknown player found: #{player_id}"
    end

    new_start = FantasyStart.new(
      points: fantasy_points,
      fantasy_team: fantasy_team,
      player: player,
      year: year,
      week: week,
      position: position,
    )

    return new_start
  end
end

def determine_playoff_week_teams(driver, current_league_url, week)
  playoff_week_team_ids = []
  driver.navigate.to current_league_url
  doc = Nokogiri::HTML(driver.page_source)
  if week == 14
    pw = ".pw-0"
    pg = [".pg-1", ".pg-2"]
  elsif week == 15
    pw = ".pw-1"
    pg = [".pg-0", ".pg-1"]
  elsif week == 16
    pw = ".pw-2"
    pg = [".pg-0"]
  end

  games_blocks = doc.css(pw)

  pg.each do |li|
    game = games_blocks.css(li)
    names = game.css(".nameWrap")
    names.each do |name|
      id = name.css("a")[0]["href"].split("/").last.to_i
      playoff_week_team_ids.push(id)
    end
  end

  return playoff_week_team_ids
end
