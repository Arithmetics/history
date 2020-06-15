class HomeController < ApplicationController
  def show
    @scheduled_games = ScheduledFantasyGame.includes(away_fantasy_team: :owner, home_fantasy_team: :owner).order(week: :asc).limit(6)
  end
end
