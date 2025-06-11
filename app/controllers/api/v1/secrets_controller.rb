module Api
  module V1
    class SecretsController < ApplicationController
      def index
        @secrets = Secret.accessible_by(current_user)
      end

      def show
        load_secret
        load_user_access

      rescue ActiveRecord::RecordNotFound
        render_not_found
      end

      def create
        @secret = Secret.new(secret_params)

        if @secret.save
          render status: :created
        else
          render_unprocessable_entity @secret.errors.full_messages.to_sentence
        end
      end

      def destroy
        # TODO - Need permission layer for handling things like this
        load_managed_secret

        if @secret.destroy
          head :no_content
        else
          render_unprocessable_entity @secret.errors.full_messages.to_sentence
        end

      rescue ActiveRecord::RecordNotFound
        render_not_found
      end

      private

      def load_secret
        @secret = Secret
          .accessible_by(current_user)
          .find(params[:id])
      end

      def load_managed_secret
        @secret = Secret
          .managed_by(current_user)
          .find(params[:id])
      end

      def load_user_access
        # TODO - We dont actually need to do this way, we can probably just
        # use the secret_accesses association directly
        # This is a bit of a hack to get the secret_access for the current user
        @user_access = @secret
          .secret_accesses
          .find_by!(user_id: current_user.id)
      end

      def secret_params
        params.require(:secret).permit(
          :name,
          :dek_encrypted,
          items_attributes: [ :key, :content, :metadata ]
        ).tap do |p|
          p[:creator_user] = current_user
          p[:creator_dek] = p[:dek_encrypted]
        end.slice(:name, :creator_user, :creator_dek, :items_attributes)
      end
    end
  end
end
