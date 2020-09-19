class RenameColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :playoff_odds, :type, :category
  end
end
