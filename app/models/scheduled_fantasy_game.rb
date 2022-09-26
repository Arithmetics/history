require "nokogiri"

class ScheduledFantasyGame < ApplicationRecord
  belongs_to :away_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "away_fantasy_team_id"
  belongs_to :home_fantasy_team, :class_name => "FantasyTeam", :foreign_key => "home_fantasy_team_id"

  def self.get_year_schedule_from_web(driver, current_league_url, year)
    puts "started on schedule loading"
    # sleep(5)
    scheduled_games = []
    driver.navigate.to "#{current_league_url}"
    sleep(10)
    driver.navigate.to "#{current_league_url}?standingsTab=schedule"
    puts "tried to navigate to schedule"
    sleep(3)
    weeks = *(2..14)
    weeks.each do |week|
      puts "getting week #{week}"
      sleep(2)
      puts 'getting new page source'
      doc = Nokogiri::HTML(driver.page_source)
      game_list = doc.css(".scheduleContent").css(".matchup")
      game_list.each do |game|
        away_team_name = game.css(".teamWrap")[0].css("a")[0].text
        home_team_name = game.css(".teamWrap")[1].css("a")[0].text

        puts away_team_name
        puts home_team_name
        away_team = FantasyTeam.find_by(year: year, name: away_team_name)
        if away_team == nil
          throw "Could find team with name: #{away_team_name}"
        end
        home_team = FantasyTeam.find_by(year: year, name: home_team_name)
        if home_team == nil
          throw "Could find team with name: #{home_team_name}"
        end

        new_scheduled_game = ScheduledFantasyGame.new()
        new_scheduled_game.week = week
        new_scheduled_game.away_fantasy_team = away_team
        new_scheduled_game.home_fantasy_team = home_team
        scheduled_games.push(new_scheduled_game)
        puts new_scheduled_game
      end
      driver.navigate.to "#{current_league_url}?scheduleDetail=#{week+1}&scheduleType=week&standingsTab=schedule"
    end
    ActiveRecord::Base.transaction do
      scheduled_games.each { |game| game.save! }
    end
  end

  def self.remove_last_played_week()
    self.order(week: :asc).limit(6).delete_all
    puts "Remove last week passed"
  end
  ##
end
