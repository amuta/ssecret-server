module Api
  module V1
    class SecretsController < ApplicationController
      load_and_authorize_resource :secret

      def index
        @secrets = @secrets.includes(:secret_accesses)
      end

      def show
        load_user_access
      end

      def create
        result = SecretCreator.call(
          user: current_user,
          name: secret_params[:name],
          dek: secret_params[:dek_encrypted],
          items_attributes: secret_params[:items_attributes]
        )

        if result.success?
          @secret = result.payload
          render status: :created
        else
          render_unprocessable_entity result.errors.to_sentence
        end
      end

      def destroy
        if @secret.destroy
          head :no_content
        else
          render_unprocessable_entity @secret.errors.full_messages.to_sentence
        end
      end

      private

      def load_and_authorize_secret
        @secret = Secret.find(params[:id])
        authorize @secret
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
        )
      end
    end
  end
end
