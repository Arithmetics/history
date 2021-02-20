class SeasonCardsController < ApplicationController
  def index
    # all cards and who owns them
    @season_cards = SeasonCard.includes(users: :owner, season_stat: { player: {} }).all
  end

  def show
    # cards for one owner
  end

  ########## private #########
  private
end
