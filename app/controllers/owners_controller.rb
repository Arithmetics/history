class OwnersController < ApplicationController
  def index
    @owners = Owner.all.includes(:fantasy_teams, :away_fantasy_games, :home_fantasy_games)
  end
end
