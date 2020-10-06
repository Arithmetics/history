class AddOwnerToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :owner, null: true, foreign_key: true
  end
end
