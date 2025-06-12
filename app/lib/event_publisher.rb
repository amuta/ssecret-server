module EventPublisher
  def self.publish(event)
    event.metadata[:correlation_id] = Current.correlation_id
    event.metadata[:user_id] = Current.user&.id

    ActiveSupport::Notifications.instrument(event.event_name, event)
  end
end
