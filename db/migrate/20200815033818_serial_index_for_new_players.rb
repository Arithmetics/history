class SerialIndexForNewPlayers < ActiveRecord::Migration[6.0]
  def change
    execute "SELECT setval('players_id_seq', 9000000)"
  end
end
