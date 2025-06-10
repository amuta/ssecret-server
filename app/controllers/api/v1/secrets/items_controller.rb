module Api
  module V1
    module Secrets
      class ItemsController < ApplicationController
        # reading (index/show) requires any access
        before_action :load_readable_secret, only: [ :index, :show ]

        # mutating (create/update/destroy) requires write or admin
        before_action :load_changeable_secret, only: [ :create, :update, :destroy ]
        before_action :load_item,              only: [ :show, :update, :destroy ]

        def index
          @items = @secret.items
        end

        def show; end

        def create
          @item = @secret.items.build(item_params)
          if @item.save
            render status: :created
          else
            render_unprocessable_entity @item.errors.full_messages.to_sentence
          end
        end

        def update
          if @item.update(item_params)
            head :no_content
          else
            render_unprocessable_entity @item.errors.full_messages.to_sentence
          end
        end

        def destroy
          @item.destroy
          head :no_content
        end

        private

        def load_readable_secret
          @secret = Secret.accessible_by(current_user).find(params[:secret_id])
        rescue ActiveRecord::RecordNotFound
          render_not_found
        end

        def load_changeable_secret
          @secret = Secret.changeable_by(current_user).find(params[:secret_id])
        rescue ActiveRecord::RecordNotFound
          render_not_found
        end

        def load_item
          @item = @secret.items.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_not_found
        end

        def item_params
          params.require(:item).permit(:key, :content, metadata: {})
        end
      end
    end
  end
end
