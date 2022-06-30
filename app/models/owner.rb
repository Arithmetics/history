require "nokogiri"
require "open-uri"

class Owner < ApplicationRecord
  validates_uniqueness_of :name
  validates :name, presence: true

  belongs_to :user
  has_many :fantasy_teams
  has_many :away_fantasy_games, through: :fantasy_teams
  has_many :home_fantasy_games, through: :fantasy_teams

  has_many :purchases, through: :fantasy_teams

  def self.changed_on_web?(driver, current_league_url)
    sleep(2)
    driver.navigate.to "#{current_league_url}/owners"
    sleep(4)
    driver.navigate.to "#{current_league_url}/owners"
    doc = Nokogiri::HTML(driver.page_source)
    page_owners = doc.css(".userName")
    puts page_owners
    owner_count = 0
    page_owners.each do |owner|
      x = Owner.find_by_name(owner.text)
      if x != nil
        puts "Found #{x.name}"
        owner_count += 1
      else
        puts "didnt find #{owner.text}"
      end
    end

    if owner_count != 12
      raise "Detected a new owner!"
    end

    puts "check_owners passed"
  end

  def versus_records
    all_games_edit = [].push()
    @away_fantasy_games = self.away_fantasy_games
    @home_fantasy_games = self.home_fantasy_games
    @away_fantasy_games.each do |game|
      new_game = { year: game.year, week: game.week, versus: game.home_fantasy_team.owner, win?: false }
      if game.away_score > game.home_score
        new_game[:win?] = true
      end

      all_games_edit.push(new_game)
    end
    @home_fantasy_games.each do |game|
      new_game = { year: game.year, week: game.week, versus: game.away_fantasy_team.owner, win?: false }
      if game.home_score > game.away_score
        new_game[:win?] = true
      end
      all_games_edit.push(new_game)
    end
    all_games_edit.sort_by! { |game| [game[:year], game[:week]] }
    game_records = {}
    all_games_edit.each do |game|
      versus_owner_id = game[:versus].id
      if game_records[versus_owner_id] == nil
        game_records[versus_owner_id] = { id: game[:versus].id, name: game[:versus].name, wins: 0, losses: 0, streak: 0 }
      end
      if game[:win?]
        game_records[versus_owner_id][:wins] += 1
        if game_records[versus_owner_id][:streak] > 0
          game_records[versus_owner_id][:streak] += 1
        else
          game_records[versus_owner_id][:streak] = 1
        end
      else
        game_records[versus_owner_id][:losses] += 1
        if game_records[versus_owner_id][:streak] < 0
          game_records[versus_owner_id][:streak] -= 1
        else
          game_records[versus_owner_id][:streak] = -1
        end
      end
    end
    versus_records = []
    game_records.each { |k, record| versus_records.push(record) }
    return versus_records
  end

  def cumulative_stats
    total_points = 0
    total_games = 0
    total_wins = 0
    @away_fantasy_games = self.away_fantasy_games.where(week: 1..13, year: 0...2020).or(where(week: 1..14, year: 2021...9999))
    @home_fantasy_games = self.home_fantasy_games.where(week: 1..13, year: 0...2020).or(where(week: 1..14, year: 2021...9999))

    @away_fantasy_games.each do |game|
      total_games += 1
      total_points += game.away_score
      if game.away_score > game.home_score
        total_wins += 1
      end
    end

    @home_fantasy_games.each do |game|
      total_games += 1
      total_points += game.home_score
      if game.home_score > game.away_score
        total_wins += 1
      end
    end

    points_per_game = total_games > 0 ? (total_points / total_games).round(2) : 0

    total_playoff_points = 0
    total_playoff_games = 0
    total_playoff_wins = 0
    @away_playoff_games = self.away_fantasy_games.where(week: 14..16, year: 0...2020).or(where(week: 15..17, year: 2021...9999))

   

    @home_fantasy_games = self.home_fantasy_games.where(week: 14..16, year: 0...2020).or(where(week: 15..17, year: 2021...9999))

    @away_playoff_games.each do |game|
      total_playoff_games += 1
      total_playoff_points += game.away_score
      if game.away_score > game.home_score
        total_playoff_wins += 1
      end
    end

    @home_fantasy_games.each do |game|
      total_playoff_games += 1
      total_playoff_points += game.home_score
      if game.home_score > game.away_score
        total_playoff_wins += 1
      end
    end

    playoff_points_per_game = total_playoff_games > 0 ? (total_playoff_points / total_playoff_games).round(2) : 0

    return { "total_points" => total_points.round(2), "total_games" => total_games, "total_wins" => total_wins, "points_per_game" => points_per_game, "total_playoff_points" => total_playoff_points.round(2), "total_playoff_games" => total_playoff_games, "total_playoff_wins" => total_playoff_wins, "playoff_points_per_game" => playoff_points_per_game }
  end
end
