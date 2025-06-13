Rails.application.config.to_prepare do
  AUDIT_LISTENER = Auditing::Listener.new

  ActiveSupport::Notifications.subscribe(/audit\./) do |*args|
    event = ActiveSupport::Notifications::Event.new(*args).payload
    AUDIT_LISTENER.handle(event)
  end
end
