class FantasyTeamsController < ApplicationController
  def show
    @fantasy_team = FantasyTeam.includes(fantasy_starts: :player, purchases: :player, away_fantasy_games: {home_fantasy_team: {}, away_fantasy_team: {}}, home_fantasy_games: {home_fantasy_team: {}, away_fantasy_team: {}}).find(params[:id])
  end
end
