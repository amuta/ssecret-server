Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :sessions, only: :create

      resource :me, only: :show, controller: "me"

      namespace :me do
        resources :secret_sets, only: [ :index, :show ]
      end
    end
  end
end
