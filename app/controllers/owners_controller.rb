class OwnersController < ApplicationController
  def index
    @owners = Owner.all.includes(:fantasy_teams, :away_fantasy_games, :home_fantasy_games)
  end

  def show
    @owner = Owner.includes(fantasy_teams: { away_fantasy_games: {away_fantasy_team: :owner, home_fantasy_team: :owner}, home_fantasy_games: {away_fantasy_team: :owner, home_fantasy_team: :owner} }, away_fantasy_games: {}, home_fantasy_games: {}).find(params[:id])
  end
end
