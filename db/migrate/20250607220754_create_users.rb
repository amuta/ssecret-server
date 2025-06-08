class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.text :ssh_public_key

      t.timestamps
    end
    add_index :users, :username
  end
end
