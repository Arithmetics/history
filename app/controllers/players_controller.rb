class PlayersController < ApplicationController
  def index
    @players = Player.all
    render json: @players
  end

  def show
    @player = Player.find(params[:id])

    render json: @player
  end

  ########## private #########
  private

  def player_params
    params.require(:person).permit(:name, :birthdate)
  end
end
