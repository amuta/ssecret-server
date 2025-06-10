module Api
  module V1
    module Me
      class SecretSetsController < ApplicationController
        def index
          @secret_sets  = current_user.secret_sets
        end

        def show
          @secret_set = SecretSet
            .left_outer_joins(:secret_set_accesses)
            .where("secret_sets.created_by_user_id = :uid OR secret_set_accesses.user_id = :uid",
                   uid: current_user.id)
            .distinct
            .find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { success: false, error: "Not found" }, status: :not_found
        end
      end
    end
  end
end
