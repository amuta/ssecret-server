module AuditHelper
  def capture_events(topic = /audit\./)
    events = []
    callback = ->(*args) { events << ActiveSupport::Notifications::Event.new(*args) }

    ActiveSupport::Notifications.subscribed(callback, topic) do
      yield
    end

    events
  end
end
