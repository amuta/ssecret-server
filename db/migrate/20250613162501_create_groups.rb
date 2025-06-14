class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.boolean :is_personal, default: false, null: false

      t.timestamps
    end

    add_index :groups, :name, unique: true
  end
end
