class AddByeWeekToRankings < ActiveRecord::Migration[6.0]
  def change
    add_column :rankings, :bye_week, :integer
  end
end
