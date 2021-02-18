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
        id = row["id"].to_i
        year = row[0].to_i
        ranking_num = row["rank"].to_i
        position = row["position"]
        player = Player.find(id)
        if player == nil
          throw("unknonw player #{id} mentioned")
        end

        ranking = Ranking.new(ranking: ranking_num, year: year, position: position, player: player)
        puts player.name
        ranking.save!
      end
    end
  end

  def was_projected_top_performer
    if (self.position === 'QB') 
      return self.ranking < 12
    end
    if (self.position === 'RB' || self.position === 'WR') 
      return self.ranking < 22
    end
    if (self.position === 'TE') 
      return self.ranking < 8
    end
    return false
  end
end
