class AddDefaultNflUrls < ActiveRecord::Migration[6.0]
  def up
    Player.all.each do |player|
      player.nfl_URL_name = player.name.gsub(" ", "-").gsub(".", "-").gsub("--", "-").downcase
      player.save!
    end
    x = Player.find(2507175).nfl_URL_name = "steve-smith-2"
    x.save!
    y = Player.find(2508048).nfl_URL_name = "mike-williams-4"
    y.save!
    z = Player.find(2506140).nfl_URL_name = "ryan-grant-2"
    z.save!
  end

  def down
    Player.all.each do |player|
      player.nfl_URL_name = ""
      player.save!
    end
  end
end
