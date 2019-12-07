class FantasyTeam < ApplicationRecord
  belongs_to :owner
  has_many :fantasy_starts
  has_many :purchases
  has_many :away_fantasy_games, :class_name => "FantasyGame", :foreign_key => "away_fantasy_team_id"
  has_many :home_fantasy_games, :class_name => "FantasyGame", :foreign_key => "home_fantasy_team_id"

  validates :name, presence: true
  validates :year, presence: true

  def won_game?(week)
    away_fantasy_game = self.away_fantasy_games.where(week: week).first
    home_fantasy_game = self.home_fantasy_games.where(week: week).first

    if away_fantasy_game != nil
      if away_fantasy_game.away_score > away_fantasy_game.home_score
        return true
      end
      return false
    end

    if home_fantasy_game != nil
      if home_fantasy_game.home_score > home_fantasy_game.away_score
        return true
      end
      return false
    end
    return false
  end

  def played_in_week?(week)
    away_fantasy_game = self.away_fantasy_games.where(week: week)
    home_fantasy_game = self.home_fantasy_games.where(week: week)
  end

  def season_points
    points = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..13)
    away_fantasy_games.each { |game| points += game.away_score }
    home_fantasy_games.each { |game| points += game.home_score }
    return points
  end

  def season_wins
    wins = 0
    away_fantasy_games = self.away_fantasy_games.where(week: 1..13)
    home_fantasy_games = self.home_fantasy_games.where(week: 1..13)
    away_fantasy_games.each { |game| (game.away_score > game.home_score) ? wins += 1 : nil }
    home_fantasy_games.each { |game| (game.home_score > game.away_score) ? wins += 1 : nil }
    return wins
  end

  def made_playoffs?
    if self.away_fantasy_games.where(week: 14..15).length > 0 || self.home_fantasy_games.where(week: 14..15).length > 0
      return true
    end
    return false
  end

  def made_finals?
    if self.away_fantasy_games.where(week: 16).length > 0 || self.home_fantasy_games.where(week: 16).length > 0
      return true
    end
    return false
  end

  def won_championship?
    away_finals = self.away_fantasy_games.where(week: 16)

    home_finals = home_fantasy_games.where(week: 16)

    away_finals.each do |final|
      if final.away_score > final.home_score
        return true
      end
    end

    home_finals.each do |final|
      if final.home_score > final.away_score
        return true
      end
    end

    return false
  end
end
