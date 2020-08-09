class AddYearToPlayoffOdds < ActiveRecord::Migration[6.0]
  def change
    add_column :playoff_odds, :year, :integer
  end
end
