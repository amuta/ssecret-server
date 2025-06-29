module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authenticate_request!, only: [ :create ]

      def create
        user = User.authenticate_by(login_params)

        if user
          token = user.generate_jwt
          render json: { token: token }
        else
          render json: { error: "Invalid username or password" }, status: :unauthorized
        end
      end

      private

      def login_params
        params.require(:user).permit(:username, :password)
      end
    end
  end
end
