Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :sessions, only: :create

      resource :me, only: :show, controller: "me"

      resources :secrets, only: [ :index, :show, :create, :update, :destroy ] do
        resources :items, only: [ :show, :create, :update, :destroy ],
                  module: :secrets
        resources :accesses, only: [ :index, :create, :update, :destroy ], controller: "secrets/accesses"
      end
    end
  end
end
