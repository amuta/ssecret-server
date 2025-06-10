class AddMetadataToSecrets < ActiveRecord::Migration[8.0]
  def change
    add_column :secrets, :metadata, :jsonb, default: {}
  end
end