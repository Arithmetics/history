require "nokogiri"
require "open-uri"

class SeasonStat < ApplicationRecord
  belongs_to :player
  before_save :set_default_values
  validates :games_played, numericality: { greater_than: 0 }

  def set_default_values
    self.passing_completions = 0 if self.passing_completions.nil?
    self.passing_attempts = 0 if self.passing_attempts.nil?
    self.passing_yards = 0 if self.passing_yards.nil?
    self.passing_touchdowns = 0 if self.passing_touchdowns.nil?
    self.interceptions = 0 if self.interceptions.nil?
    self.rushing_attempts = 0 if self.rushing_attempts.nil?
    self.rushing_yards = 0 if self.rushing_yards.nil?
    self.rushing_touchdowns = 0 if self.rushing_touchdowns.nil?
    self.receiving_yards = 0 if self.receiving_yards.nil?
    self.receptions = 0 if self.receptions.nil?
    self.receiving_touchdowns = 0 if self.receiving_touchdowns.nil?
    self.fumbles_lost = 0 if self.fumbles_lost.nil?
  end

  def calculate_season_fantasy_points
    passing_points = (self.passing_yards / 25.0) + (self.passing_touchdowns * 4.0)
    # puts passing_points
    rushing_points = (self.rushing_yards / 10.0) + (self.rushing_touchdowns * 6.0)
    # puts rushing_points
    receiving_points = (self.receiving_yards / 10.0) + (self.receiving_touchdowns * 6.0)
    # puts receiving_points
    negative_points = (self.fumbles_lost * 2.0 + self.interceptions * 2.0)
    # puts negative_points
    total_points = passing_points + rushing_points + receiving_points - negative_points

    return total_points.round(2)
  end

  def calculate_season_fantasy_points_ppr
    ppr_points = self.calculate_season_fantasy_points + (self.receptions * 0.5)
    return ppr_points.round(2)
  end

  def self.get_season_stats_from_player_page(url)
    season_stats = {}
    begin
      doc = Nokogiri::HTML(open(url))
    rescue OpenURI::HTTPError => ex
      throw "could not open url: #{url}"
    end
    position = doc.css(".nfl-c-player-header__position").text.squish
    stat_tables = doc.css(".nfl-o-roster")
    stat_tables.each do |stat_table|
      stat_type = stat_table.css(".nfl-t-stats__title")[0].text.squish.downcase
      table_rows = stat_table.css("tbody").css("tr")
      table_rows.each do |row|
        cells = row.css("td")
        year = cells[0].text.squish.downcase
        if season_stats[year] == nil
          season_stats[year] = SeasonStat.new()
          season_stats[year].year = year
        end
        season_stats[year].position = position
        if stat_type == "passing"
          season_stats[year].games_played = cells[2].text
          season_stats[year].passing_completions = cells[3].text
          season_stats[year].passing_attempts = cells[4].text
          season_stats[year].passing_yards = cells[6].text
          season_stats[year].passing_touchdowns = cells[9].text
          season_stats[year].interceptions = cells[10].text
        elsif stat_type == "rushing"
          season_stats[year].games_played = cells[2].text
          season_stats[year].rushing_attempts = cells[3].text
          season_stats[year].rushing_yards = cells[4].text
          season_stats[year].rushing_touchdowns = cells[7].text
        elsif stat_type == "receiving"
          season_stats[year].games_played = cells[2].text
          season_stats[year].receptions = cells[3].text
          season_stats[year].receiving_yards = cells[4].text
          season_stats[year].receiving_touchdowns = cells[7].text
        elsif stat_type == "fumbles"
          season_stats[year].games_played = cells[2].text
          season_stats[year].fumbles_lost = cells[3].text
        end
      end
    end
    return season_stats
  end

  def self.set_all_season_points
    total_count = SeasonStat.all.count()
    current = 0
    SeasonStat.all.each do |stat|
      current += 1
      stat.fantasy_points_reg = stat.calculate_season_fantasy_points
      stat.fantasy_points_ppr = stat.calculate_season_fantasy_points_ppr
      puts "#{current}/#{total_count} setting season points"
      stat.save!
    end
  end

  def self.set_all_experience
    total_count = SeasonStat.all.count()
    current = 0
    SeasonStat.all.each do |stat|
      current += 1
      stat.experience_at_season = SeasonStat.where("player_id = ? AND year <= ?", stat.player.id, stat.year).count
      puts "#{current}/#{total_count} setting experience"
      stat.save!
    end
  end

  def self.set_all_ranks
    total_count = SeasonStat.all.count()
    current = 0
    SeasonStat.all.each do |stat|
      current += 1
      stat.rank_reg = SeasonStat.where("fantasy_points_reg >= ? AND year = ? AND position = ?", stat.fantasy_points_reg, stat.year, stat.position).count
      stat.rank_ppr = SeasonStat.where("fantasy_points_ppr >= ? AND year = ? AND position = ?", stat.fantasy_points_ppr, stat.year, stat.position).count
      puts "#{current}/#{total_count} settings ranks"
      stat.save!
    end
  end
  ###
end
