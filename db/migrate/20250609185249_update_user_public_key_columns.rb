class UpdateUserPublicKeyColumns < ActiveRecord::Migration[8.0]
  def change
    # Rename existing column
    rename_column :users, :ssh_public_key, :public_key

    # Add new hash column with index
    add_column :users, :public_key_hash, :string
    add_index :users, :public_key_hash, unique: true
  end
end
