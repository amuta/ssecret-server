module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    result = authenticate_user
    if result.success?
      @current_user = result.user
      Current.user = @current_user
    else
      render_unauthorized(result.error_message)
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
