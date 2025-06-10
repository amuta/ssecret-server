class AdjustSecretSetsSchema < ActiveRecord::Migration[8.0]
  def change
    # Remove DEK from secret_sets as it shouldn't be stored there
    remove_column :secret_sets, :dek_encrypted, :text
    
    # Add permissions to secret_set_accesses
    add_column :secret_set_accesses, :permissions, :integer, default: 0
  end
end