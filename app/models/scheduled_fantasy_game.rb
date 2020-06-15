require "nokogiri"

class ScheduledFantasyGame < ApplicationRecord
  belongs_to :away_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "away_fantasy_team_id"
  belongs_to :home_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "home_fantasy_team_id"

  def self.get_year_schedule_from_web(driver, current_league_url, year)
    "got in here"
    scheduled_games = []
    driver.navigate.to "#{current_league_url}?standingsTab=schedule"
    sleep(3)
    weeks = *(1..13)
    weeks.each do |week|
      puts "getting week #{week}"
      sleep(2)
      doc = Nokogiri::HTML(driver.page_source)
      game_list = doc.css(".scheduleContent").css(".matchup")
      game_list.each do |game|
        away_team_name = game.css(".teamWrap")[0].css("a").text
        home_team_name = game.css(".teamWrap")[0].css("a").text

        away_team = FantasyTeam.find_by(year: year, name: away_team_name)
        if away_team == nil
          throw "Could find team with name: #{away_team_name}"
        end
        home_team = FantasyTeam.find_by(year: year, name: home_team_name)
        if away_owner == nil
          throw "Could find team with name: #{home_team_name}"
        end

        new_scheduled_game = ScheduledFantasyGame.new(
          week: week,
          away_fantasy_team: away_fantasy_team,
          home_fantasy_team: home_fantasy_team,
        )
        scheduled_games.push(new_scheduled_game)
      end
      if week != 13
        next_week = driver.find_element(xpath: "/html/body/div[1]/div[3]/div/div[2]/div/div[5]/div/div[2]/div/div/div[2]/div/ul[1]/li[2]/a")
        next_week.click()
        sleep(2)
      end
    end
    ActiveRecord::Base.transaction do
      scheduled_games.each { |game| game.save! }
    end
  end
  ##
end
