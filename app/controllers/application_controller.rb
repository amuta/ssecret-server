class ApplicationController < ActionController::API
  before_action :authenticate_user!

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_user = User.from_jwt(token)

    unless @current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
