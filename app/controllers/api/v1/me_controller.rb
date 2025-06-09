module Api
  module V1
    class MeController < ApplicationController
      def show
        render json: {
          success: true,
          data: {
            username: current_user.username,
            id: current_user.id
          }
        }
      end
    end
  end
end
