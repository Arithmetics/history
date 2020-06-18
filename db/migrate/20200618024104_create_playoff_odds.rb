class CreatePlayoffOdds < ActiveRecord::Migration[6.0]
  def change
    create_table :playoff_odds do |t|
      t.integer :week
      t.string :type
      t.float :odds
      t.belongs_to :fantasy_team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
