class HomeController < ApplicationController
  def show
    @scheduled_games = ScheduledFantasyGame.includes(away_fantasy_team: :owner, home_fantasy_team: :owner).order(week: :asc).limit(6)

    @owners = Owner.all.includes(fantasy_teams: { away_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner }, home_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner } }, away_fantasy_games: {}, home_fantasy_games: {})

    current_year = FantasyStart.maximum("year")
    current_week = FantasyStart.where(year: current_year).maximum("week")

    @first_starts = FantasyStart.includes(:player).where(week: current_week, year: current_year).where.not(position: "BN").where.not(position: "RES").where(player_id: FantasyStart.where.not(position: "BN").group(:player_id).having("count(*) = 1").select(:player_id))

    @playoff_odds = PlayoffOdd.includes(:fantasy_team).where(year: current_year, week: current_week)

    @standings = FantasyTeam.includes(owner: {}, away_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner }, home_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner }).where(year: current_year)
  end

  ##
end
