class StaticController < ApplicationController
  def welcome
    @message = { message: "api up and running" }
    render json: @message
  end
end
