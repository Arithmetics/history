class OwnersController < ApplicationController
  def index
    @owners = Owner.all.includes(:fantasy_teams)
    render json: @owners, include: 'fantasy_teams'
  end
end
