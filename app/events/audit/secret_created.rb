module Audit
  class SecretCreated < BaseEvent
    private

    def audit_log_attributes
      {
        user:           Current.user,
        auditable:      secret,
        action:         :secret_created,
        status:         :success,
        correlation_id: metadata[:correlation_id],
        details:        { name: secret.name }
      }
    end
  end
end
