require "nokogiri"

class Player < ApplicationRecord
  has_many :fantasy_starts
  has_many :purchases
  has_many :season_stats
  validates :name, presence: true

  def career_stats
    position = ""
    total_starts = 0
    total_benchings = 0
    total_points = 0
    playoff_points = 0
    finals_points = 0
    championships = 0
    total_auction_money = 0
    highest_auction_money = 0
    best_start = 0
    best_reg_rank = 999
    best_ppr_rank = 999

    self.fantasy_starts.each do |start|
      if ["QB", "RB", "WR", "TE", "Q/R/W/T", "K", "DEF"].include?(start.position)
        total_starts += 1
        total_points += start.points
        if best_start < start.points
          best_start = start.points
        end
        if [14, 15, 16].include?(start.week)
          playoff_points += start.points
        end
        if start.week == 16
          finals_points += start.points

          if start.fantasy_team.won_game?(start.week)
            championships += 1
          end
        end
      end
    end

    self.purchases.each do |purchase|
      total_auction_money += purchase.price
      if highest_auction_money < purchase.price
        highest_auction_money = purchase.price
      end
    end

    self.season_stats.select { |s| s.year > 2010 }.each do |stat|
      position = stat.position
      if best_reg_rank > stat.rank_reg
        best_reg_rank = stat.rank_reg
      end

      if best_ppr_rank > stat.rank_ppr
        best_ppr_rank = stat.rank_ppr
      end
    end

    career_stats = {}
    career_stats["position"] = position
    career_stats["total_starts"] = total_starts
    career_stats["playoff_points"] = playoff_points.round(2)
    career_stats["finals_points"] = finals_points.round(2)
    career_stats["total_points"] = total_points.round(2)
    career_stats["championships"] = championships.round(2)

    career_stats["total_auction_money"] = total_auction_money
    career_stats["highest_auction_money"] = highest_auction_money
    career_stats["best_start"] = best_start
    career_stats["best_reg_rank"] = best_reg_rank
    career_stats["best_ppr_rank"] = best_ppr_rank

    return career_stats
  end

  def self.insert_new_players_from_file(filepath)
    ActiveRecord::Base.transaction do
      CSV.foreach(filepath, :headers => true) do |row|
        owner_name = row["owner_name"]
        player_name = row["name"]
        player_id = row["profile_id"].to_i
        birthdate = Date.strptime(row["birthdate"], "%m/%d/%Y")
        picture_id = row["picture_id"]

        player = Player.new(name: player_name, id: player_id, birthdate: birthdate, picture_id: picture_id)
        puts "New player created: #{player.name}"
        player.save!
      end
    end
  end

  def self.find_name_match(year, name)
    id_matches = []
    potentials = Player.where(name: name)
    potentials.each do |player|
      if player.fantasy_starts.where(year: year).count > 0
        id_matches.push(player.id)
      end
    end
    return id_matches
  end

  def self.update_all_season_stats
    i = 0
    Player.all.each do |player|
      i += 1
      if player.nfl_URL_name != nil && player.nfl_URL_name != ""
        puts "#{i} INVESTIGATION on #{player.name}"

        player_url = "https://www.nfl.com/players/#{player.nfl_URL_name.squish}/stats/"
        all_player_seasons = SeasonStat.get_season_stats_from_player_page(player_url)

        all_player_seasons.each do |year, nfl_season|
          found_count = nfl_season.games_played
          db_count = 0
          existing_db_season = player.season_stats.where(year: year).first
          if existing_db_season != nil
            db_count = existing_db_season.games_played
          end
          if db_count != found_count && nfl_season.position != "K" && nfl_season.games_played != nil
            if existing_db_season != nil
              puts "deleting season for #{existing_db_season.player.name}, year: #{existing_db_season.year}, games played: #{existing_db_season.games_played}"
              puts "XXX"
              puts "XXX"
              puts "XXX"
              puts "ALERT!!!"
              puts "XXX"
              puts "XXX"
              puts "XXX"
              existing_db_season.delete
            end
            nfl_season.player = player
            season_start = Date.parse("#{nfl_season.year}-09-01")
            birthdate = player.birthdate
            nfl_season.age_at_season = ((season_start - birthdate) / 365).to_f.round(2)
            puts "adding new season for #{nfl_season.player.name}, year: #{nfl_season.year}, games played: #{nfl_season.games_played}"
            nfl_season.save!
          end
        end
      end
    end
  end

  def self.find_and_create_unknown_players_regular(driver, current_league_url, week)
    team_ids = *(1..12)
    self.find_and_create_unknown_players(driver, current_league_url, week, team_ids)
  end

  def find_and_create_unknown_players_playoffs(driver, current_league_url, week)
    team_ids = FantasyGame.determine_playoff_week_teams(driver, current_league_url, week)
    self.find_and_create_unknown_players(driver, current_league_url, week, team_ids)
  end

  def self.find_and_create_unknown_players(driver, current_league_url, week, team_numbers)
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
      new_players.push(self.scrape_unknown_player(driver, id))
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

  ## needs to be updated, will need to see how this will be navigatable to (guess the naem? arg!!!!)
  def self.scrape_unknown_player(driver, id)
    driver.navigate.to "http://www.nfl.com/player/mattryan/#{id}/profile"
    doc = Nokogiri::HTML(driver.page_source)
    new_player = Player.new
    # this will need to change
    new_player.id = id
    new_player.name = doc.css(".nfl-c-player-header__title").text.squish
    birthdate_string = doc.css(".nfl-c-player-info__detail").text.split(" ")[1]
    new_player.birthdate = Date.strptime(birthdate_string, "%m/%d/%Y")
    # new_player.picture_id = doc.css(".player-photo").css("img")[0]["src"].split("/").last.gsub(".png", "")
    # this needs to be updated
    return new_player
  end

  ##
end
