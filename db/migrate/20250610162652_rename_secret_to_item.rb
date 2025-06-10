class RenameSecretToItem < ActiveRecord::Migration[8.0]
  def change
    rename_table :secrets, :items
  end
end
