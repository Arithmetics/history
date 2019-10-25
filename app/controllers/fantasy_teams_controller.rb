class FantasyTeamsController < ApplicationController
  def show
    @fantasy_team = FantasyTeam.includes(fantasy_starts: :player, purchases: :player).find(params[:id])
  end
end
