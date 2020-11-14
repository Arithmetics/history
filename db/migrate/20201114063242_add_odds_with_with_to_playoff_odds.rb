class AddOddsWithWithToPlayoffOdds < ActiveRecord::Migration[6.0]
  def change
    add_column :playoff_odds, :odds_with_win, :float, default: 0
    add_column :playoff_odds, :odds_with_loss, :float, default: 0
  end
end
