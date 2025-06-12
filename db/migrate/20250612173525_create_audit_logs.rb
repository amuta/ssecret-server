class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, foreign_key: true
      t.references :auditable, polymorphic: true, null: false
      t.integer :action, null: false
      t.integer :status, null: false
      t.jsonb :details, default: {}

      t.timestamps
    end
    add_index :audit_logs, :action
  end
end
