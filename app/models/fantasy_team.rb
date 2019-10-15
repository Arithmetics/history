class FantasyTeam < ApplicationRecord
  belongs_to :owner
  has_many :fantasy_starts
  has_many :away_fantasy_games, :class_name => "FantasyGame", :foreign_key => "away_fantasy_team_id"
  has_many :home_fantasy_games, :class_name => "FantasyGame", :foreign_key => "home_fantasy_team_id"

  validates :name, presence: true
  validates :year, presence: true

  def season_points
    puts self.name
    points = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..13)
    away_fantasy_games.each { |game| points += game.away_score }
    home_fantasy_games.each { |game| points += game.home_score }
    return points
  end
end
