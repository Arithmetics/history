class Owner < ApplicationRecord
  validates_uniqueness_of :name
  validates :name, presence: true

  has_many :fantasy_teams
  has_many :away_fantasy_games, through: :fantasy_teams
  has_many :home_fantasy_games, through: :fantasy_teams

  has_many :purchases, through: :fantasy_teams

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

    total_playoff_points = 0
    total_playoff_games = 0
    total_playoff_wins = 0
    @away_playoff_games = self.away_fantasy_games.where(week: 14..16)
    @home_fantasy_games = self.home_fantasy_games.where(week: 14..16)

    @away_playoff_games.each do |game|
      total_playoff_games += 1
      total_playoff_points += game.away_score
      if game.away_score > game.home_score
        total_playoff_wins += 1
      end
    end

    @home_fantasy_games.each do |game|
      total_playoff_games += 1
      total_playoff_points += game.home_score
      if game.home_score > game.away_score
        total_playoff_wins += 1
      end
    end

    playoff_points_per_game = total_playoff_games > 0 ? (total_playoff_points / total_playoff_games).round(2) : 0

    return { "total_points" => total_points.round(2), "total_games" => total_games, "total_wins" => total_wins, "points_per_game" => points_per_game, "total_playoff_points" => total_playoff_points.round(2), "total_playoff_games" => total_playoff_games, "total_playoff_wins" => total_playoff_wins, "playoff_points_per_game" => playoff_points_per_game }
  end
end
