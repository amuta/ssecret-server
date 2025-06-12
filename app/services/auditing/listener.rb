module Auditing
  class Listener
    def on_authorization_failed(event)
      AuditLog.create!(
        user: Current.user,
        auditable: event.record,
        action: :authorization_failed,
        status: :failure,
        details: {
          permission_checked: event.query,
          correlation_id: event.metadata[:correlation_id],
          ip_address: event.request.remote_ip
        }
      )
    end

    def on_secret_created(event)
      AuditLog.create!(
        user: Current.user,
        auditable: event.secret,
        action: :secret_created,
        status: :success,
        details: {
          name: event.secret.name,
          correlation_id: event.metadata[:correlation_id]
        }
      )
    end

    def on_secret_destroyed(event)
      AuditLog.create!(
        user: Current.user,
        auditable: event.secret,
        action: :secret_destroyed,
        status: :success,
        details: {
          name: event.secret.name,
          correlation_id: event.metadata[:correlation_id]
        }
      )
    end
  end
end
