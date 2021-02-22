class AddUsEffectToCardOwnership < ActiveRecord::Migration[6.0]
  def change
    add_reference :season_card_ownerships, :season_card_effect
  end
end
