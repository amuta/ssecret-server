class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.text :ssh_public_key

      t.timestamps
    end
    add_index :users, :email
  end
end
