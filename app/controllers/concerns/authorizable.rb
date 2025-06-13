module Authorizable
  extend ActiveSupport::Concern

  included do
    # TODO: Maybe verify if we authorized every request
  end

  private

  def authorize(record, query = nil)
    query ||= :"#{action_name}?"
    policy_class = "#{record.class.name}Policy".constantize
    policy = policy_class.new(current_user, record)

    return if policy.public_send(query)

    event = Audit::AuthorizationFailed.new(record: record, query: query, request: request)
    EventPublisher.publish(event)
    render_unauthorized("You are not authorized to perform this action.")
  end

  def policy_scope(scope)
    policy_scope_class = "#{scope.name}Policy::Scope".constantize
    policy_scope_class.new(current_user, scope).resolve
  end

  module ClassMethods
    def load_and_authorize_resource(resource_name, options = {})
      parent_name = options[:parent]
      action_map = options.fetch(:map_actions, {})

      before_action do
        parent_resource = nil
        resource_class = resource_name.to_s.classify.constantize

        if parent_name
          parent_class = parent_name.to_s.classify.constantize
          parent_resource = parent_class.find(params[:"#{parent_name}_id"])
          instance_variable_set("@#{parent_name}", parent_resource)
        end

        query = action_map.fetch(action_name.to_sym, :"#{action_name}?")

        if params[:id]
          scope = parent_resource ? parent_resource.send(resource_name.to_s.pluralize) : resource_class
          resource = scope.find(params[:id])
          authorize resource, query
          instance_variable_set("@#{resource_name}", resource)
        else
          if action_name == "index"
            scope = parent_resource ? parent_resource.send(resource_name.to_s.pluralize) : resource_class
            instance_variable_set("@#{resource_name.to_s.pluralize}", policy_scope(scope))
          elsif action_name == "create"
            authorizeable = parent_resource.send(resource_name.to_s.pluralize).build if parent_resource
            authorizeable ||= resource_class.new
            authorize authorizeable, query
          end
        end
      end
    end
  end
end
