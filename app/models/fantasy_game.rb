require "nokogiri"

class FantasyGame < ApplicationRecord
  belongs_to :away_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "away_fantasy_team_id"
  belongs_to :home_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "home_fantasy_team_id"

  # need to validate only one game per owner per week

  def self.get_regular_season_fantasy_games(driver, current_league_url, year, week)
    team_ids = *(1..12)
    self.get_fantasy_games(driver, current_league_url, year, week, team_ids)
  end

  def self.get_playoff_fantasy_games(driver, current_league_url, year, week)
    team_ids = determine_playoff_week_team_ids(driver, current_league_url, week)
    self.get_fantasy_games(driver, current_league_url, year, week, team_ids)
  end

  def self.get_fantasy_games(driver, current_league_url, year, week, team_numbers)
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

          away_team = self.find_by(name: away_team_name, year: year)
          home_team = self.find_by(name: home_team_name, year: year)

          if away_team == nil
            raise "Cant find a match for team: #{away_team_name}"
          end
          if home_team == nil
            raise "Cant find a match for team: #{home_team_name}"
          end
          self.create!(
            year: year,
            week: week,
            away_fantasy_team: away_team,
            away_score: away_team_score,
            home_fantasy_team: home_team,
            home_score: home_team_score,
          )
        end
      end
    end
  end

  def self.determine_playoff_week_team_ids(driver, current_league_url, week)
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
  ####

end
