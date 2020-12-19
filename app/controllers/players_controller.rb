class PlayersController < ApplicationController
  before_action :authenticate_admin!, only: [:create, :update, :destroy]

  def index
    @players = Player.includes(fantasy_starts: { fantasy_team: { owner: {}, home_championship_games: {}, away_championship_games: {}  } }, purchases: { fantasy_team: :owner }, season_stats: {}, rankings: {}).all
  end

  def show
    @player = Player.includes(fantasy_starts: { fantasy_team: :owner }, purchases: { fantasy_team: :owner }, season_stats: {}, rankings: {}).find(params[:id])
  end

  def create
    id = params[:player]["id"]
    name = params[:player]["name"]
    picture_id = params[:player]["picture_id"]
    nfl_URL_name = params[:player]["nfl_URL_name"]
    birthdate = params[:player]["birthdate"].to_date

    @player = Player.create!(id: id, name: name, picture_id: picture_id, nfl_URL_name: nfl_URL_name, birthdate: birthdate)
  end

  def update
    id = params[:player]["id"]
    name = params[:player]["name"]
    picture_id = params[:player]["picture_id"]
    nfl_URL_name = params[:player]["nfl_URL_name"]
    birthdate = params[:player]["birthdate"].to_date

    @player = Player.find(id)

    @player.update!(id: id, name: name, picture_id: picture_id, nfl_URL_name: nfl_URL_name, birthdate: birthdate)
  end

  def destroy
    @player = Player.find(params[:id])
    @player.delete
  end

  ########## private #########
  private

  def player_params
    params.require(:player).permit(:id, :name, :birthdate, :picture_id, :nfl_URL_name)
  end
end
