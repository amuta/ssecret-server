class Api::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :login ]
  def login
    user = User.authenticate_by(login_params)

    if user
      token = user.generate_jwt
      render json: { token: token }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
