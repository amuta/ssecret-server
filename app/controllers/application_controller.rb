class ApplicationController < ActionController::API
  before_action :authenticate_request!

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
end
