class RenameSecretAccessPermissionsAndDek < ActiveRecord::Migration[8.0]
  def change
    rename_column :secret_accesses, :permissions, :role
    rename_column :secret_accesses, :dek_encrypted, :encrypted_dek
  end
end
