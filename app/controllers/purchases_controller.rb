class PurchasesController < ApplicationController
  def index
    @purchases = Purchase.includes(fantasy_team: :owner, player: { season_stats: {}, rankings: {} }).all.order(year: :desc, price: :desc)
  end

  ########## private #########
  private
end
