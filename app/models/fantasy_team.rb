require "nokogiri"

class FantasyTeam < ApplicationRecord
  belongs_to :owner
  has_many :fantasy_starts
  has_many :purchases
  has_many :away_fantasy_games, :class_name => "FantasyGame", :foreign_key => "away_fantasy_team_id"
  has_many :home_fantasy_games, :class_name => "FantasyGame", :foreign_key => "home_fantasy_team_id"

  validates :name, presence: true
  validates :year, presence: true
  validates :owner, uniqueness: { scope: :year,
                                  message: "only one team per owner per year" }

  def self.get_current_website_team_owners_and_names(driver, current_league_url)
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

  def self.create_all_teams_on_web(driver, current_league_url, year)
    team_map = self.get_current_website_team_owners_and_names(driver, current_league_url)
    begin
      ActiveRecord::Base.transaction do
        team_map.each do |k, v|
          owner = Owner.find_by_name(k)
          if owner == nil
            raise "Missing owner: #{k}!"
          end
          puts "Creating new team: #{v} for owner #{owner.name}"
          self.create!(owner: owner, year: year, name: v)
        end
      end
    end
    puts "create_all_teams_on_web passed"
  end

  def self.update_team_names_from_web(driver, current_league_url, year)
    team_map = self.get_current_website_team_owners_and_names(driver, current_league_url)
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
    end
    puts "update_team_names_from_web passed"
  end

  def won_game?(week)
    away_fantasy_game = self.away_fantasy_games.where(week: week).first
    home_fantasy_game = self.home_fantasy_games.where(week: week).first

    if away_fantasy_game != nil
      if away_fantasy_game.away_score > away_fantasy_game.home_score
        return true
      end
      return false
    end

    if home_fantasy_game != nil
      if home_fantasy_game.home_score > home_fantasy_game.away_score
        return true
      end
      return false
    end
    return false
  end

  def played_in_week?(week)
    away_fantasy_game = self.away_fantasy_games.where(week: week)
    home_fantasy_game = self.home_fantasy_games.where(week: week)
  end

  def season_points
    points = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..13)
    away_fantasy_games.each { |game| points += game.away_score }
    home_fantasy_games.each { |game| points += game.home_score }
    return points
  end

  def season_wins
    wins = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..13)
    away_fantasy_games.each { |game| (game.away_score > game.home_score) ? wins += 1 : nil }
    home_fantasy_games.each { |game| (game.home_score > game.away_score) ? wins += 1 : nil }
    return wins
  end

  def made_playoffs?
    if self.away_fantasy_games.where(week: 14..15).length > 0 || self.home_fantasy_games.where(week: 14..15).length > 0
      return true
    end
    return false
  end

  def made_finals?
    if self.away_fantasy_games.where(week: 16).length > 0 || self.home_fantasy_games.where(week: 16).length > 0
      return true
    end
    return false
  end

  def won_championship?
    away_finals = self.away_fantasy_games.where(week: 16)

    home_finals = home_fantasy_games.where(week: 16)

    away_finals.each do |final|
      if final.away_score > final.home_score
        return true
      end
    end

    home_finals.each do |final|
      if final.home_score > final.away_score
        return true
      end
    end

    return false
  end

  def generate_random_score
    scores = self.away_fantasy_games.select(:away_score).pluck(:away_score).concat(self.home_fantasy_games.select(:home_score).pluck(:home_score))
    average = scores.inject(0) { |accum, i| accum + i } / scores.length.to_f
    standard_deviation = Math.sqrt(scores.inject(0) { |accum, i| accum + (i - average) ** 2 } / (scores.length() - 1).to_f)
    generator = RandomGaussian.new(average, standard_deviation)
    return generator.rand
  end

  ##
end
