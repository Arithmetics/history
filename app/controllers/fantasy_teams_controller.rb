class FantasyTeamsController < ApplicationController
  def show
    @fantasy_team = FantasyTeam.includes(fantasy_starts: :player, purchases: :player, away_fantasy_games: { home_fantasy_team: { fantasy_starts: :player }, away_fantasy_team: { fantasy_starts: :player } }, 
    home_fantasy_games: { home_fantasy_team: { fantasy_starts: :player }, away_fantasy_team: { fantasy_starts: :player } }).find(params[:id])
  end

  def index
    @fantasy_teams = FantasyTeam.includes(:owner).all
  end
end
