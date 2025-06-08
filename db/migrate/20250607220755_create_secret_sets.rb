class CreateSecretSets < ActiveRecord::Migration[8.0]
  def change
    create_table :secret_sets do |t|
      t.string :name
      t.integer :created_by_user_id
      t.text :dek_encrypted

      t.timestamps
    end
    add_index :secret_sets, :created_by_user_id
  end
end
