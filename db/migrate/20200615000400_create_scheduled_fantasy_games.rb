class CreateScheduledFantasyGames < ActiveRecord::Migration[6.0]
  def change
    create_table :scheduled_fantasy_games do |t|
      t.integer :week
      t.references :away_fantasy_team
      t.references :home_fantasy_team

      t.timestamps
    end
    add_foreign_key :scheduled_fantasy_games, :fantasy_teams, column: :away_fantasy_team_id, primary_key: :id
    add_foreign_key :scheduled_fantasy_games, :fantasy_teams, column: :home_fantasy_team_id, primary_key: :id
  end
end
