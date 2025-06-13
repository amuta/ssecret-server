module Auditing
  class Listener
    def handle(event)
      event.audit! if event.respond_to?(:audit!)
    end
  end
end
