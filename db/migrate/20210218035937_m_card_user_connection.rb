class MCardUserConnection < ActiveRecord::Migration[6.0]
  def change
    create_table :season_card_ownerships do |t|
      t.belongs_to :user
      t.belongs_to :season_card
      t.integer        :serial_number
      t.timestamps
    end
  end
end
