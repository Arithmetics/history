class FantasyTeamsController < ApplicationController
  def show
    @fantasy_team = FantasyTeam.includes(fantasy_starts: :player).find(params[:id])
    # render json: @fantasy_team.to_json(include: { fantasy_starts: { include: :player } })
  end
end
