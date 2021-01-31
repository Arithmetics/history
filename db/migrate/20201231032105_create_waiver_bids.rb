class CreateWaiverBids < ActiveRecord::Migration[6.0]
  def change
    create_table :waiver_bids do |t|
      t.integer :amount
      t.integer :year
      t.integer :week
      t.boolean :winning
      t.belongs_to :fantasy_team, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
