class SeasonCardsController < ApplicationController
  def index
    # all cards and who owns them
    @season_cards = SeasonCard.includes(users: :owner, season_stat: { player: {} }).all
  end

  def show
    # a users cards params is the owner_id
    @season_cards = []
    owner = Owner.find(params[:id])
    if owner == nil
      @season_cards = []
    end
    user = owner.user

    @season_card_ownerships = owner.user.season_card_ownerships.includes(season_card: {season_stat: {player: {}}})

  end

  ########## private #########
  private
end
