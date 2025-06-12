class ApplicationController < ActionController::API
  before_action :authenticate_request!

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render_not_found
  end


  private

  def render_not_found(message = nil)
    message ||= "Resource"
    message += " "
    render json: { success: false, error: "#{message}Not Found" }, status: :not_found
  end

  def render_unprocessable_entity(message)
    render json: { success: false, error: message },
                 status: :unprocessable_entity
  end

  def render_unauthorized(message)
    render json: { success: false, error: message || "Unauthorized" },
                 status: :unauthorized
  end

  def authenticate_request!
    result = authenticate_user
    if result.success?
      @current_user = result.user
    else
      render json: result, status: :unauthorized
    end
  end

  def authenticate_user
    return jwt_authentication if jwt_auth_header?
    return signature_authentication if signature_auth_headers?
    Authentication::Result.new(error_code: :missing_params)
  end

  def jwt_auth_header?
    request.headers["Authorization"]&.start_with?("Bearer ")
  end

  def signature_auth_headers?
    request.headers["X-Signature"].present? && request.headers["X-Timestamp"].present?
  end

  def jwt_authentication
    token = request.headers["Authorization"].split(" ").last
    user = User.from_jwt(token)
    Authentication::Result.new(user: user)
  rescue
    Authentication::Result.new(error_code: :invalid_auth)
  end

  def signature_authentication
    SignatureAuthenticator.new(request).authenticate
  end

  def current_user
    @current_user
  end

  def authorize(record, query)
    # Infers policy class from the record, e.g., Secret -> SecretPolicy
    policy_class = "#{record.class.name}Policy".constantize
    policy = policy_class.new(current_user, record)

    return if policy.public_send(query)

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

        # 1. Load Parent if applicable
        if parent_name
          parent_class = parent_name.to_s.classify.constantize
          parent_resource = parent_class.find(params[:"#{parent_name}_id"])
          instance_variable_set("@#{parent_name}", parent_resource)
        end

        # 2. Determine which permission to check
        query = action_map.fetch(action_name.to_sym, :"#{action_name}?")

        # 3. Load and/or Authorize based on action type
        if params[:id]
          # Member actions: show, update, destroy
          scope = parent_resource ? parent_resource.send(resource_name.to_s.pluralize) : resource_class
          resource = scope.find(params[:id])
          authorize resource, query
          instance_variable_set("@#{resource_name}", resource)
        else
          # Collection actions: index, create
          if action_name == "index"
            scope = parent_resource ? parent_resource.send(resource_name.to_s.pluralize) : resource_class
            instance_variable_set("@#{resource_name.to_s.pluralize}", policy_scope(scope))
          elsif action_name == "create"
            # For create, we authorize against the parent if one exists,
            # otherwise we authorize against a new instance of the resource class
            # but modify the query to include the child resource.
            authorizeable = parent_resource.send(resource_name.to_s.pluralize).build if parent_resource
            authorizeable ||= resource_class.new
            authorize authorizeable, query
          end
        end
      rescue ActiveRecord::RecordNotFound => e
        render_not_found(e.model || "Resource")
      end
    end
  end
  extend ClassMethods
end
