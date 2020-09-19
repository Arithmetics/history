class CreateRankings < ActiveRecord::Migration[6.0]
  def change
    create_table :rankings do |t|
      t.references :player, null: false, foreign_key: true
      t.integer :year
      t.string :position
      t.integer :ranking

      t.timestamps
    end
  end
end
