class PlayersController < ApplicationController
  def index
    @players = Player.all
    render json: @players
  end

  def show
    @player = Player.includes(fantasy_starts: {fantasy_team: :owner}).find(params[:id])
  end

  ########## private #########
  private

  def player_params
    params.require(:person).permit(:name, :birthdate)
  end
end
