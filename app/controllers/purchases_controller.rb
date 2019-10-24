class PurchasesController < ApplicationController
  def index
    @purchases = Purchase.includes(fantasy_team: :owner, player: {}).all.order(year: :desc, price: :desc)
  end

  def show
    @purchases = Purchase.includes(fantasy_team: :owner, player: {}).where(year: params[:id]).sort_by { |purchase| purchase.year }
  end

  ########## private #########
  private
end
