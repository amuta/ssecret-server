module Api
  module V1
    module Me
      class SecretSetsController < ApplicationController
        def index
          @secret_sets = current_user.secret_sets.includes(:secrets)
          @created_secret_sets = SecretSet.where(created_by: current_user)
        end
      end
    end
  end
end
