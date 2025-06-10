class AdjustSecretSetsSchema < ActiveRecord::Migration[8.0]
  def change
    remove_column :secret_sets, :dek_encrypted, :text

    add_column :secret_set_accesses, :permissions, :integer, default: 0
  end
end
