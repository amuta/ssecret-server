class AddGroupToSecretAccesses < ActiveRecord::Migration[8.0]
  def change
    add_reference :secret_accesses, :group, null: true, foreign_key: true
  end
end
