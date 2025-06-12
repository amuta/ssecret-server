Rails.application.config.to_prepare do
  AUDIT_LISTENER = Auditing::Listener.new

  EVENT_MAP = {
    "audit.authorization_failed.v1" => :on_authorization_failed,
    "audit.secret_created.v1"       => :on_secret_created,
    "audit.secret_destroyed.v1"     => :on_secret_destroyed,
    "audit.user_login_failed.v1"    => :on_user_login_failed
  }.freeze

  EVENT_MAP.each do |event_name, method_name|
    ActiveSupport::Notifications.subscribe(event_name) do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      # The payload from ActiveSupport::Notifications is the last argument
      AUDIT_LISTENER.public_send(method_name, event.payload)
    end
  end
end
