class CreateSeasonCardEffects < ActiveRecord::Migration[6.0]
  def change
    create_table :season_card_effects do |t|
      t.string :color_one
      t.string :color_two
      t.string :effect_image_url

      t.timestamps
    end
  end
end
