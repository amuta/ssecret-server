class DropCreatedByFromSecretSets < ActiveRecord::Migration[8.0]
  def change
    remove_index :secret_sets, :created_by_user_id if index_exists?(:secret_sets, :created_by_user_id)
    remove_column :secret_sets, :created_by_user_id, :integer
  end
end
