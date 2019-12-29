class Player < ApplicationRecord
  has_many :fantasy_starts
  has_many :purchases
  has_many :season_stats
  validates :name, presence: true

  def career_stats
    position = ""
    total_starts = 0
    total_benchings = 0
    total_points = 0
    playoff_points = 0
    finals_points = 0
    championships = 0
    total_auction_money = 0
    highest_auction_money = 0
    best_start = 0
    best_reg_rank = 999
    best_ppr_rank = 999

    self.fantasy_starts.each do |start|
      if ["QB", "RB", "WR", "TE", "Q/R/W/T", "K", "DEF"].include?(start.position)
        total_starts += 1
        total_points += start.points
        if best_start < start.points
          best_start = start.points
        end
        if [14, 15, 16].include?(start.week)
          playoff_points += start.points
        end
        if start.week == 16
          finals_points += start.points

          if start.fantasy_team.won_game?(start.week)
            championships += 1
          end
        end
      end
    end

    self.purchases.each do |purchase|
      total_auction_money += purchase.price
      if highest_auction_money < purchase.price
        highest_auction_money = purchase.price
      end
    end

    self.season_stats.select { |s| s.year > 2010 }.each do |stat|
      position = stat.position
      if best_reg_rank > stat.rank_reg
        best_reg_rank = stat.rank_reg
      end

      if best_ppr_rank > stat.rank_ppr
        best_ppr_rank = stat.rank_ppr
      end
    end

    career_stats = {}
    career_stats["position"] = position
    career_stats["total_starts"] = total_starts
    career_stats["playoff_points"] = playoff_points.round(2)
    career_stats["finals_points"] = finals_points.round(2)
    career_stats["total_points"] = total_points.round(2)
    career_stats["championships"] = championships.round(2)

    career_stats["total_auction_money"] = total_auction_money
    career_stats["highest_auction_money"] = highest_auction_money
    career_stats["best_start"] = best_start
    career_stats["best_reg_rank"] = best_reg_rank
    career_stats["best_ppr_rank"] = best_ppr_rank

    return career_stats
  end

  def self.insert_new_players(filepath)
    ActiveRecord::Base.transaction do
      CSV.foreach(filepath, :headers => true) do |row|
        owner_name = row["owner_name"]
        price = row["price"].to_i
        player_name = row["name"]
        player_id = row["profile_id"].to_i
        birthdate = row["birthdate"]
        picture_id = row["picture_id"]

        player = Player.new(name: player_name, id: player_id, birthdate: birthdate, picture_id: picture_id)

        player.save!
      end
    end
  end

  def self.find_name_match(year, name)
    id_matches = []
    potentials = Player.where(name: name)
    potentials.each do |player|
      if player.fantasy_starts.where(year: year).count > 0
        id_matches.push(player.id)
      end
    end
    return id_matches
  end
end
