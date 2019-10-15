class CreateFantasyGames < ActiveRecord::Migration[6.0]
  def change
    create_table :fantasy_games do |t|
      t.integer :year
      t.integer :week
      t.references :away_fantasy_team
      t.references :home_fantasy_team
      t.float :away_score
      t.float :home_score

      t.timestamps
    end
    add_foreign_key :fantasy_games, :fantasy_teams, column: :away_fantasy_team_id, primary_key: :id
    add_foreign_key :fantasy_games, :fantasy_teams, column: :home_fantasy_team_id, primary_key: :id
  end
end
