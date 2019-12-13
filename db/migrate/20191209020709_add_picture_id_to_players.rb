class AddPictureIdToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :picture_id, :string
  end
end
