module Api
  module V1
    class SecretsController < ApplicationController
      load_and_authorize_resource :secret

      def index
        @secrets = @secrets.includes(
          :items,
          secret_accesses: { group: :group_memberships }
        )
      end

      def show; end

      def create
        result = ::Secrets::CreateService.call(
          user: current_user,
          group_id: secret_params[:group_id],
          name: secret_params[:name],
          dek: secret_params[:encrypted_dek],
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
          event = Audit::SecretDestroyed.new(secret: @secret)
          EventPublisher.publish(event)
          head :no_content
        else
          render_unprocessable_entity @secret.errors.full_messages.to_sentence
        end
      end

      private

      def secret_params
        params.require(:secret).permit(
          :group_id,
          :name,
          :encrypted_dek,
          items_attributes: [ :key, :content, :metadata ]
        )
      end
    end
  end
end
