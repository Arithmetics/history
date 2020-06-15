class HomeController < ApplicationController
  def show
    @scheduled_games = ScheduledFantasyGame.includes(away_fantasy_team: :owner, home_fantasy_team: :owner).order(week: :asc).limit(6)
    @owners = Owner.all.includes(fantasy_teams: { away_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner }, home_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner } }, away_fantasy_games: {}, home_fantasy_games: {})
  end
end
