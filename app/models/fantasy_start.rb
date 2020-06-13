require "nokogiri"

class FantasyStart < ApplicationRecord
  belongs_to :fantasy_team
  belongs_to :player

  validates :points, presence: true
  validates :year, presence: true
  validates_inclusion_of :week, :in => 1..16
  validates :position, presence: true, inclusion: { in: %w{QB RB WR TE DEF K BN Q/R/W/T RES} }

  def self.get_fantasy_starts_regular(driver, current_league_url, year, week)
    team_ids = *(1..12)
    self.get_fantasy_starts(driver, current_league_url, year, week, team_ids)
  end

  def self.get_fantasy_starts_playoffs(driver, current_league_url, year, week)
    team_ids = FantasyGame.determine_playoff_week_teams(driver, current_league_url, week)
    self.get_fantasy_starts(driver, current_league_url, year, week, team_ids)
  end

  def self.get_fantasy_starts(driver, current_league_url, year, week, team_numbers)
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

  def self.get_start_from_row(row, fantasy_team, year, week)
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

  ##
end
