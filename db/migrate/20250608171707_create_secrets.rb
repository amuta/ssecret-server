class CreateSecrets < ActiveRecord::Migration[8.0]
  def change
    create_table :secrets do |t|
      t.string :key
      t.text :content
      t.references :secret_set, null: false, foreign_key: true

      t.timestamps
    end
  end
end
