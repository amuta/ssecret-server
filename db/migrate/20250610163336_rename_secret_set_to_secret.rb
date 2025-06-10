class RenameSecretSetToSecret < ActiveRecord::Migration[8.0]
  def change
    rename_table :secret_sets, :secrets
    rename_column :items, :secret_set_id, :secret_id
    rename_column :secret_set_accesses, :secret_set_id, :secret_id

    # Update the foreign key constraint if it exists
    if foreign_key_exists?(:items, :secret_sets)
      remove_foreign_key :items, :secret_sets
      add_foreign_key :items, :secrets, column: :secret_id
    end

    if foreign_key_exists?(:secret_set_accesses, :secret_sets)
      remove_foreign_key :secret_set_accesses, :secret_sets
      add_foreign_key :secret_set_accesses, :secrets, column: :secret_id
    end
  end
end
