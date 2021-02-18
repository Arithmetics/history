class CreateSeasonCards < ActiveRecord::Migration[6.0]
  def change
    create_table :season_cards do |t|
      t.references :season_stat, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: true
      t.integer :auction_price
      t.boolean :breakout
      t.boolean :repeat
      t.boolean :champion
      t.timestamps
    end
  end
end
