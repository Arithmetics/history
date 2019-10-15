class Owner < ApplicationRecord
  validates_uniqueness_of :name
  validates :name, presence: true

  has_many :fantasy_teams
  has_many :away_fantasy_games, through: :fantasy_teams
  has_many :home_fantasy_games, through: :fantasy_teams

  def cumulative_stats
    total_points = 0
    total_games = 0
    total_wins = 0
    @away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    @home_fantasy_games = self.home_fantasy_games.where(week: 1..13)

    @away_fantasy_games.each do |game|
      total_games += 1
      total_points += game.away_score
      if game.away_score > game.home_score
        total_wins += 1
      end
    end

    @home_fantasy_games.each do |game|
      total_games += 1
      total_points += game.home_score
      if game.home_score > game.away_score
        total_wins += 1
      end
    end

    points_per_game = (total_points / total_games).round(2)

    return { "total_points" => total_points.round(2), "total_games" => total_games, "total_wins" => total_wins, "points_per_game" => points_per_game }
  end
end
