module Api
  module V1
    module Me
      class SecretSetsController < ApplicationController
        def index
          @secret_sets = SecretSet.accessible_by(current_user)
        end

        def show
          @secret_set = SecretSet
            .accessible_by(current_user)
            .find(params[:id])

          @user_access = @secret_set
            .secret_set_accesses
            .find_by!(user_id: current_user.id)
        rescue ActiveRecord::RecordNotFound
          render json: { success: false, error: "Not found" }, status: :not_found
        end
      end
    end
  end
end
