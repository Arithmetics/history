class HomeController < ApplicationController
  def show
    @scheduled_games = ScheduledFantasyGame.includes(away_fantasy_team: :owner, home_fantasy_team: :owner).order(week: :asc).limit(6)

    @owners = Owner.all.includes(fantasy_teams: { away_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner }, home_fantasy_games: { away_fantasy_team: :owner, home_fantasy_team: :owner } }, away_fantasy_games: {}, home_fantasy_games: {})

    @first_starts = FantasyStart.includes(:player).where(week: 4, year: 2019).where.not(position: "BN").where(player_id: FantasyStart.where.not(position: "BN").group(:player_id).having("count(*) = 1").select(:player_id))

    @playoff_odds = PlayoffOdd.includes(:fantasy_team).where(year: PlayoffOdd.maximum(:year))
  end
end
