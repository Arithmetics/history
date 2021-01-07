require "nokogiri"

class FantasyTeam < ApplicationRecord
  belongs_to :owner
  belongs_to :waiver_bid
  has_many :fantasy_starts
  has_many :purchases

  has_many :away_fantasy_games, :class_name => "FantasyGame", :foreign_key => "away_fantasy_team_id"
  has_many :home_fantasy_games, :class_name => "FantasyGame", :foreign_key => "home_fantasy_team_id"
  has_many :home_championship_games, -> { where(week: 16) }, :class_name => "FantasyGame", :foreign_key => "home_fantasy_team_id"
  has_many :away_championship_games, -> { where(week: 16) }, :class_name => "FantasyGame", :foreign_key => "away_fantasy_team_id"

  scope :included_weeks_starts, -> (week) { includes(fantasy_starts: :player).where(fantasy_starts: { week: week})} 

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

  def self.get_current_website_team_pictures(driver, current_league_url)
    driver.navigate.to "#{current_league_url}/owners"

    doc = Nokogiri::HTML(driver.page_source)
    owner_table = doc.css("#leagueOwners")
    rows = owner_table.css("tbody").css("tr")
    team_map = {}
    rows.each do |row|
      team = row.css(".teamName").text
      image_ref = row.css(".teamImg").css("img")[0]["src"]
      team_map[team] = image_ref
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

  def self.update_team_names_and_pictures_from_web(driver, current_league_url, year)
    team_map = self.get_current_website_team_owners_and_names(driver, current_league_url)
    image_map = self.get_current_website_team_pictures(driver, current_league_url)
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
          team_image = image_map[fantasy_team.name]
          fantasy_team.update!(picture_url: team_image)
        end
      end
    end
    puts "update_team_names_and_pictures_from_web passed"
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

  def season_losses
    losses = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..13)
    away_fantasy_games.each { |game| (game.away_score < game.home_score) ? losses += 1 : nil }
    home_fantasy_games.each { |game| (game.home_score < game.away_score) ? losses += 1 : nil }
    return losses
  end

  # weeks where finished in top 6
  def top_six_wins
    top_six_wins = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..13)

    away_fantasy_games.each do |game|
      away_teams_beaten = FantasyGame.where("away_score < ?", game.away_score).where(year: self.year, week: game.week).count
      home_teams_beaten = FantasyGame.where("home_score < ?", game.away_score).where(year: self.year, week: game.week).count
      if (away_teams_beaten + home_teams_beaten) > 5
        top_six_wins += 1
      end
    end

    home_fantasy_games.each do |game|
      away_teams_beaten = FantasyGame.where("away_score < ?", game.home_score).where(year: self.year, week: game.week).count
      home_teams_beaten = FantasyGame.where("home_score < ?", game.home_score).where(year: self.year, week: game.week).count
      if (away_teams_beaten + home_teams_beaten) > 5
        top_six_wins += 1
      end
    end
    return top_six_wins
  end

  def breakdown_wins_by_week(week)
    breakdown_wins = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..week)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..week)

    away_fantasy_games.each do |game|
      breakdown_wins += FantasyGame.where("away_score < ?", game.away_score).where(year: self.year, week: game.week).count
      breakdown_wins += FantasyGame.where("home_score < ?", game.away_score).where(year: self.year, week: game.week).count
    end

    home_fantasy_games.each do |game|
      breakdown_wins += FantasyGame.where("away_score < ?", game.home_score).where(year: self.year, week: game.week).count
      breakdown_wins += FantasyGame.where("home_score < ?", game.home_score).where(year: self.year, week: game.week).count
    end
    return breakdown_wins
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
    away_finals = self.away_championship_games

    home_finals = self.home_championship_games

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
    if standard_deviation.to_f.nan?
      standard_deviation = 35 # week 1 std
    end
    generator = RandomGaussian.new(average, standard_deviation)
    return generator.rand
  end

  def position_category_stats
    pts_by_position_regular = {
      'QB' => 0,
      'RB' => 0,
      'WR' => 0,
      'TE' => 0,
      'K' => 0,
      'DEF' => 0,
    }

    pts_by_position_playoffs = {
      'QB' => 0,
      'RB' => 0,
      'WR' => 0,
      'TE' => 0,
      'K' => 0,
      'DEF' => 0,
    }

    starts_by_position_regular = {
      'QB' => 0,
      'RB' => 0,
      'WR' => 0,
      'TE' => 0,
      'K' => 0,
      'DEF' => 0,
    }

    starts_by_position_playoffs = {
      'QB' => 0,
      'RB' => 0,
      'WR' => 0,
      'TE' => 0,
      'K' => 0,
      'DEF' => 0,
    }

    starts = self.fantasy_starts.where.not(position: ['BN', 'RES'])
    starts.each do |start|

      if pts_by_position_regular[start.position]
        if [14,15,16].include?(start.week)
          pts_by_position_playoffs[start.position] += start.points.round(0)
          starts_by_position_playoffs[start.position] += 1
        else
          pts_by_position_regular[start.position] += start.points.round(0)
          starts_by_position_regular[start.position] += 1

          if start.position === 'K'
            puts start.player.name
            puts start.week
          end
        end

      else
        position = start.player.season_stats.order("year DESC").first.position
        if [14,15,16].include?(start.week)
          pts_by_position_playoffs[position] += start.points.round(0)
          starts_by_position_playoffs[position] += 1
        else
          x = pts_by_position_regular[position]
          pts_by_position_regular[position] += start.points.round(0)
          starts_by_position_regular[position] += 1
        end
      end
    end
    return {
              "ptsByPositionRegular" => pts_by_position_regular,
              "ptsByPositionPlayoffs" => pts_by_position_playoffs,
              "startsByPositionRegular" => starts_by_position_regular,
              "startsByPositionPlayoffs" => starts_by_position_playoffs
            }
  end

  ##
end
