class WaiverBidsController < ApplicationController
  before_action :authenticate_admin!, only: [:create, :update, :destroy]

  def index
    @bids = WaiverBid.includes(player: {}, fantasy_team: :owner).all
  end

  def show
    @bids = WaiverBid.includes(player: {}, fantasy_team: :owner).find(params[:id])
  end

  def create
    id = params[:waiver_bid]["id"]
    year = params[:waiver_bid]["year"]
    week = params[:waiver_bid]["week"]
    amount = params[:waiver_bid]["amount"]
    winning = params[:waiver_bid]["winning"]
    player_id = params[:waiver_bid]["player_id"]
    fantasy_team_id = params[:waiver_bid]["fantasy_team_id"]

    @bid = WaiverBid.create!(id: id, year: year, week: week, amount: amount, winning: winning, player_id: player_id, fantasy_team_id: fantasy_team_id)
  end

  def update
    id = params[:waiver_bid]["id"]
    year = params[:waiver_bid]["year"]
    week = params[:waiver_bid]["week"]
    amount = params[:waiver_bid]["amount"]
    winning = params[:waiver_bid]["winning"]
    player_id = params[:waiver_bid]["player_id"]
    fantasy_team_id = params[:waiver_bid]["fantasy_team_id"]

    @bid = WaiverBid.find(id)

    @bid = WaiverBid.update!(id: id, year: year, week: week, amount: amount, winning: winning, player_id: player_id, fantasy_team_id: fantasy_team_id)
  end

  def destroy
    @bid = WaiverBid.find(params[:id])
    @bid.delete
  end

  ########## private #########
  private

  def waiver_bid_params
    params.require(:waiver_bid).permit(:id, :week, :year, :amount, :winning, :fantasy_team_id, :player_id)
  end
end
