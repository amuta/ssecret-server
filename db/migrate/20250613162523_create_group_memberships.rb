class CreateGroupMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.text :encrypted_group_key, null: false

      t.timestamps
    end
    add_index :group_memberships, [ :user_id, :group_id ], unique: true
  end
end
