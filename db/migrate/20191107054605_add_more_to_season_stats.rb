class AddMoreToSeasonStats < ActiveRecord::Migration[6.0]
  def change
    add_column :season_stats, :position, :string
    add_column :season_stats, :rank_reg, :integer
    add_column :season_stats, :rank_ppr, :integer
    add_column :season_stats, :fantasy_points_reg, :float
    add_column :season_stats, :fantasy_points_ppr, :float
  end
end
