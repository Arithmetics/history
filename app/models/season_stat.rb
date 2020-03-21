class SeasonStat < ApplicationRecord
  belongs_to :player

  def calculate_season_fantasy_points
    passing_points = (self.passing_yards / 25.0) + (self.passing_touchdowns * 4.0)
    # puts passing_points
    rushing_points = (self.rushing_yards / 10.0) + (self.rushing_touchdowns * 6.0)
    # puts rushing_points
    receiving_points = (self.receiving_yards / 10.0) + (self.receiving_touchdowns * 6.0)
    # puts receiving_points
    negative_points = (self.fumbles_lost * 2.0 + self.interceptions * 2.0)
    # puts negative_points
    total_points = passing_points + rushing_points + receiving_points - negative_points

    return total_points.round(2)
  end

  def calculate_season_fantasy_points_ppr
    ppr_points = self.calculate_season_fantasy_points + (self.receptions * 0.5)
    return ppr_points.round(2)
  end
end
