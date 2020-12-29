require "nokogiri"

class FantasyGame < ApplicationRecord
  belongs_to :away_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "away_fantasy_team_id"
  belongs_to :home_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "home_fantasy_team_id"

  scope :included_weeks_starts, -> (week) { includes(fantasy_starts: :player).where(fantasy_starts: { week: week})} 

  validates :away_grade, presence: true, inclusion: { in: %w{F D- D D+ C- C C+ B- B B+ A- A A+ S} }

  # need to validate only one game per owner per week

  def self.get_regular_season_fantasy_games(driver, current_league_url, year, week)
    team_ids = *(1..12)
    self.get_fantasy_games(driver, current_league_url, year, week, team_ids)
    puts "get_regular_season_fantasy_games passed"
  end

  def self.get_playoff_fantasy_games(driver, current_league_url, year, week)
    team_ids = determine_playoff_week_team_ids(driver, current_league_url, week)
    self.get_fantasy_games(driver, current_league_url, year, week, team_ids)
    puts "get_playoff_fantasy_games passed!"
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

          away_team = FantasyTeam.find_by(name: away_team_name, year: year)
          home_team = FantasyTeam.find_by(name: home_team_name, year: year)

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
    sleep(2)
    driver.navigate.to current_league_url
    sleep(5)
    playoff_bracket_button = driver.find_element(:id, "playoffsItem")
    playoff_bracket_button.click()
    sleep(2)
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

  def self.grade_season_games(year)
    puts "grading season #{year}"
    scores = []
    FantasyGame.where(year: year).all.select(:home_score).each { |h| scores.push(h.home_score) }
    FantasyGame.where(year: year).all.select(:away_score).each { |h| scores.push(h.away_score) }

    average = scores.inject(0) { |accum, i| accum + i } / scores.length.to_f

    std_dev = Math.sqrt(scores.inject(0) { |accum, i| accum + (i - average) ** 2 } / (scores.length() - 1).to_f)

    self.where(year: year).find_each do |game|
      diff_from_avg_home = game.home_score - average
      number_of_std_devs_home = diff_from_avg_home / std_dev

      diff_from_avg_away = game.away_score - average
      number_of_std_devs_away = diff_from_avg_away / std_dev

      home_grade = self.convert_to_letter_grade(number_of_std_devs_home)
      away_grade = self.convert_to_letter_grade(number_of_std_devs_away)

      game.update_attributes(home_grade: home_grade, away_grade: away_grade)
    end
    puts "done grading"
  end

  def self.convert_to_letter_grade(number_of_std_devs)
    if number_of_std_devs < -2.0
      return "F"
    elsif number_of_std_devs < -1.7
      return "D-"
    elsif number_of_std_devs < -1.3
      return "D"
    elsif number_of_std_devs < -1.0
      return "D+"
    elsif number_of_std_devs < -0.7
      return "C-"
    elsif number_of_std_devs < -0.3
      return "C"
    elsif number_of_std_devs < 0.0
      return "C+"
    elsif number_of_std_devs < 0.3
      return "B-"
    elsif number_of_std_devs < 0.7
      return "B"
    elsif number_of_std_devs < 1.0
      return "B+"
    elsif number_of_std_devs < 1.3
      return "A-"
    elsif number_of_std_devs < 1.7
      return "A"
    elsif number_of_std_devs < 2
      return "A+"
    else
      return "S"
    end
  end
  ####

end
