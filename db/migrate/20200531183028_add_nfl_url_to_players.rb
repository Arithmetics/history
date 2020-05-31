class AddNflUrlToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :nfl_URL_name, :string
  end
end
