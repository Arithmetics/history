class OwnersController < ApplicationController
  def index
    @owners = Owner.all.includes(:fantasy_teams, :away_fantasy_games, :home_fantasy_games)
  end

  def show
    @owner = Owner.includes(fantasy_teams: { away_fantasy_games: {}, home_fantasy_games: {} }, away_fantasy_games: {}, home_fantasy_games: {}).find(params[:id])
  end
end
