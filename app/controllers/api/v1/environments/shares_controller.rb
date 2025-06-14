module Api
  module V1
    module Environments
      class SharesController < ApplicationController
        load_and_authorize_resource :environment, map_actions: { create: :share? }

        def create
          target_user = User.find(share_params[:user_id])
          result = EnvironmentSharer.call(
            environment: @environment,
            target_user: target_user,
            accesses_attributes: share_params[:accesses],
            role: share_params[:role]
          )

          if result.success?
            head :no_content
          else
            render_unprocessable_entity result.errors
          end
        end

        private

        def share_params
          params.require(:share).permit(:user_id, :role, accesses: [ :secret_id, :encrypted_dek ])
        end
      end
    end
  end
end
