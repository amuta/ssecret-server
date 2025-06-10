class RenameSecretSetAccessToSecretAccess < ActiveRecord::Migration[8.0]
  def change
    rename_table :secret_set_accesses, :secret_accesses
  end
end
