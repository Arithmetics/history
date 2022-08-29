require 'enumerable/statistics'

class Ranking < ApplicationRecord
  belongs_to :player

  validates :ranking, presence: true
  validates :year, presence: true
  validates :player, uniqueness: { scope: :year,
                                   message: "only one ranking per player per year" }
  validates :position, presence: true, inclusion: { in: %w{QB RB WR TE} }

  def self.insert_rankings_from_file(filepath)
    ActiveRecord::Base.transaction do
      CSV.foreach(filepath, :headers => true) do |row|
        puts row
        id = row["player_id"].to_i
        year = row["year"].to_i
        ranking_num = row["rank"].to_i
        position = row["position"]
        bye_week = row["bye_week"]
        player = Player.find(id)
        if player == nil
          throw("unknown player #{id} mentioned")
        end

        ranking = Ranking.new(ranking: ranking_num, year: year, position: position, player: player, bye_week: bye_week)
        puts player.name
        ranking.save!
      end
    end
  end

  def self.create_rankings_file_from_fpros(filepath, position, year)
    # lib/assets/fantasyProsRankings/2022/FantasyPros_2022_Draft_QB_Rankings.csv
    CSV.open("#{Rails.root}/lib/assets/fantasyProsRankings/#{year}/#{position}_potential_ranking_matches.csv", "wb") do |csv|
      csv << ["year", "rank", "name", "position", "player_id", "bye_week"]
      CSV.foreach(filepath, :headers => true) do |row|
        puts row
        rank = row["RK"].to_i
        name = row['PLAYER NAME']
        bye_week = row['BYE WEEK']
        player_id = '???'

        possible_players = Player.where(name: name).all

        if possible_players.length == 1
          player_id = possible_players.first.id
        end
        csv << [year, rank, name, position, player_id, bye_week]
      end
    end
  end

  def self.create_draft_pricing_sheet(year)
    historical_prices = {
      'QB' => {},
      'RB' => {},
      'WR' => {},
      'TE' => {}
    }
    
    all_prev_rankings = Ranking.where("year < ?", year).where("year > ?", 2012)

    
    all_prev_rankings.each do |ranking|
      year_is_last_three = year - ranking.year < 4
      
      purchase = ranking.player.purchases.where(year: ranking.year).first

      if !historical_prices[ranking.position][ranking.ranking]
        historical_prices[ranking.position][ranking.ranking] = []
      end

      if purchase && purchase.price 
        historical_prices[ranking.position][ranking.ranking].push(purchase.price)
        if (year_is_last_three)
          # count last 3 double
          historical_prices[ranking.position][ranking.ranking].push(purchase.price)
        end
      else 
        historical_prices[ranking.position][ranking.ranking].push(0)
      end

    end

    this_years_rankings = Ranking.where(year: year)

    csv_rows = [
      ['position', 'player', 'age', 'experience', 'last year rank', 'bye week', 'low price', 'high price']
    ]

    this_years_rankings.each do |x_rank|
      player = x_rank.player
      player_name = player.name
      age = ((Time.zone.now - player.birthdate.to_time) / 1.year.seconds).round(2)
      experience = player.season_stats.all.count
      bye_week = x_rank.bye_week

      prices = historical_prices[x_rank.position][x_rank.ranking]

      low_price = prices ? prices.percentile(25).round(0) : 0
      high_price = prices ? prices.percentile(75).round(0) : 0

      csv_rows.push([x_rank.position, player_name, age, experience, bye_week, low_price, high_price])

      CSV.open("#{Rails.root}/lib/assets/#{year}_draft_sheet.csv", "wb") do |csv|
        csv_rows.each do |row|
          csv << row
        end
      end
    end
  end
end
