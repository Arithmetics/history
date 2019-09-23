class CreateFantasyTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :fantasy_teams do |t|
      t.string :name
      t.integer :year
      t.belongs_to :owner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
