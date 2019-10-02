class CreateFantasyStarts < ActiveRecord::Migration[6.0]
  def change
    create_table :fantasy_starts do |t|
      t.float :points
      t.belongs_to :fantasy_team, null: false, foreign_key: true
      t.belongs_to :player, null: false, foreign_key: true
      t.integer :year
      t.integer :week
      t.string :position

      t.timestamps
    end
  end
end
