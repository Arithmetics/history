class AddGradeToFantasyGames < ActiveRecord::Migration[6.0]
  def change
    add_column :fantasy_games, :home_grade, :string, null: true
    add_column :fantasy_games, :away_grade, :string, null: true
  end
end
