class StaticController < ApplicationController
  def welcome
    @x = [4, 5, 6, 6]
    render json: @x
  end
end
