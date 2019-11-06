class CreateSeasonStats < ActiveRecord::Migration[6.0]
  def change
    create_table :season_stats do |t|
      t.integer :year
      t.integer :games_played
      t.integer :passing_completions
      t.integer :passing_attempts
      t.integer :passing_yards
      t.integer :passing_touchdowns
      t.integer :interceptions
      t.integer :rushing_attempts
      t.integer :rushing_yards
      t.integer :rushing_touchdowns
      t.integer :receiving_yards
      t.integer :receptions
      t.integer :receiving_touchdowns
      t.integer :fumbles_lost
      t.float :age_at_season
      t.integer :experience_at_season
      t.references :player, foreign_key: true
      t.timestamps
    end
  end
end
