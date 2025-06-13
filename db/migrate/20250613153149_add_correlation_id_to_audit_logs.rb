class AddCorrelationIdToAuditLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :audit_logs, :correlation_id, :string
    add_index :audit_logs, :correlation_id
  end
end
