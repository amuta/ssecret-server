class CreateSecretSetAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :secret_set_accesses do |t|
      t.integer :user_id
      t.integer :secret_set_id
      t.text :dek_encrypted

      t.timestamps
    end
    add_index :secret_set_accesses, :user_id
    add_index :secret_set_accesses, :secret_set_id
  end
end
