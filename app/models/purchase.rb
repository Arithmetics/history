require "csv"

class Purchase < ApplicationRecord
  belongs_to :fantasy_team
  belongs_to :player
  validates :player, uniqueness: { scope: :year,
                                   message: "can only be purchased once a year" }

  def self.insert_auction(filepath, year)
    ActiveRecord::Base.transaction do

      CSV.foreach(filepath, :headers => true) do |row|
        owner_name = row["owner_name"]
        price = row["price"].to_i
        player_name = row["player_name"]
        player_id = row["player_id"].to_i
        position = row["position"]

        player = Player.find(player_id)
        owner = Owner.find_by_name(owner_name)
        fantasy_team = FantasyTeam.where(owner: owner, year: year).first

        if player == nil || fantasy_team == nil
          throw("Bad player or team for player_id: #{player_id}, owner: #{owner_name}")
        end
        purchase = Purchase.new(fantasy_team: fantasy_team, price: price, player: player, position: position, year: year)
        purchase.save!
      end
    end
  end
end
