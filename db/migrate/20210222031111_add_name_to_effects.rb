class AddNameToEffects < ActiveRecord::Migration[6.0]
  def change
    add_column :season_card_effects, :name, :string
  end
end
