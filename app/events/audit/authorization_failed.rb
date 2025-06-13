module Audit
  class AuthorizationFailed < BaseEvent
    private

    def audit_log_attributes
      details = {
        permission_checked: query,
        ip_address:         request.remote_ip
      }
      details[:auditable_class] = record.class.name unless record.persisted?

      {
        user:           Current.user,
        auditable:      record.persisted? ? record : nil,
        action:         :authorization_failed,
        status:         :failure,
        correlation_id: metadata[:correlation_id],
        details:        details
      }
    end
  end
end
