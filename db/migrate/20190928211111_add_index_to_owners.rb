class AddIndexToOwners < ActiveRecord::Migration[6.0]
  def change
    add_index :owners, :name, unique: true
  end
end
