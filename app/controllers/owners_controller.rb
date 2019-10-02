class OwnersController < ApplicationController
  def index
    @owners = Owner.all.includes(:fantasy_teams)
  end
end
