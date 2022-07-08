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
        player = Player.find(id)
        if player == nil
          throw("unknown player #{id} mentioned")
        end

        ranking = Ranking.new(ranking: ranking_num, year: year, position: position, player: player)
        puts player.name
        ranking.save!
      end
    end
  end

  def self.create_rankings_file_from_fpros(filepath, position, year)
    # lib/assets/fantasyProsRankings/2022/FantasyPros_2022_Draft_QB_Rankings.csv
    CSV.open("#{Rails.root}/lib/assets/fantasyProsRankings/#{year}/#{position}_potential_ranking_matches.csv", "wb") do |csv|
      csv << ["year", "rank", "name", "position", "player_id"]
      CSV.foreach(filepath, :headers => true) do |row|
        puts row
        rank = row["RK"].to_i
        name = row['PLAYER NAME']
        player_id = 000000

        possible_players = Player.where(name: name).all

        if possible_players.length == 1
          player_id = possible_players.first.id
        end
        csv << [year, rank, name, position, player_id]
      end
    end
  end
end
