require "csv"

class Purchase < ApplicationRecord
  belongs_to :fantasy_team
  belongs_to :player
  validates :player, uniqueness: { scope: :year,
                                   message: "can only be purchased once a year" }

  def self.insert_auction(filepath, year)
    ActiveRecord::Base.transaction do
      CSV.foreach(filepath, :headers => true) do |row|
        owner_id = row["owner_id"]
        price = row["price"].to_i
        player_name = row["player_name"]
        player_id = row["player_id"].to_i
        position = row["position"]

        player = Player.find(player_id)
        owner = Owner.find(owner_id)
        fantasy_team = FantasyTeam.where(owner: owner, year: year).first

        if player == nil || fantasy_team == nil
          throw("Bad player or team for player_id: #{player_id}, owner: #{owner_name}")
        end
        purchase = Purchase.new(fantasy_team: fantasy_team, price: price, player: player, position: position, year: year)
        purchase.save!
      end
    end
    puts "insert_auction passed..."
  end

  def self.convert_raw_to_final(year)
    final_file = "#{Rails.root}/lib/assets/#{year}_final_auction.csv"
    CSV.open(final_file, "w+") do |writer|
      raw_file = "#{year}_raw_auction"
      writer << ["owner_id", "price", "position", "player_name", "player_id"]
      CSV.foreach("#{Rails.root}/lib/assets/#{raw_file}.csv", :headers => true) do |row|
        owner_id = row["owner_id"]
        price = row["price"]
        player_name = row["player_name"]
        position = row["position"]

        potential_id_matches = Player.find_name_match((year - 1), player_name)
        message = "TooMany:#{potential_id_matches.join(":")}"
        if potential_id_matches.length == 0
          message = "NotFound"
        elsif potential_id_matches.length == 1
          message = potential_id_matches[0]
        end
        writer << [owner_id, price, position, player_name, message]
      end
    end
  end
end
