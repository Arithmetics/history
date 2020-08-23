class PlayersController < ApplicationController
  def index
    @players = Player.includes(fantasy_starts: { fantasy_team: :owner }, purchases: { fantasy_team: :owner }, season_stats: {}, rankings: {}).all
  end

  def show
    @player = Player.includes(fantasy_starts: { fantasy_team: :owner }, purchases: { fantasy_team: :owner }, season_stats: {}, rankings: {}).find(params[:id])
  end

  ########## private #########
  private

  def player_params
    params.require(:person).permit(:name, :birthdate)
  end
end
