class MakeAuditableNullableOnAuditLogs < ActiveRecord::Migration[8.0]
  def change
    change_column_null :audit_logs, :auditable_type, true
    change_column_null :audit_logs, :auditable_id, true
  end
end
