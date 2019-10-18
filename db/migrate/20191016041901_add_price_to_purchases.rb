class AddPriceToPurchases < ActiveRecord::Migration[6.0]
  def change
    add_column :purchases, :price, :integer
  end
end
