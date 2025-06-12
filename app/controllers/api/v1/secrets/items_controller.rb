module Api
  module V1
    module Secrets
      class ItemsController < ApplicationController
        load_and_authorize_resource :item, parent: :secret

        def index; end

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

        def item_params
          params.require(:item).permit(:key, :content, metadata: {})
        end
      end
    end
  end
end
