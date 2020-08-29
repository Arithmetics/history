class UpdatePlayerPics < ActiveRecord::Migration[6.0]
  def change
    Player.update_all_player_pics
  end
end
