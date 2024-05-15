Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      resources :users, only: [] do
        collection do
          post :sign_up, to: 'users/sessions#create'
          post :sign_in, to: 'users/sessions#sign_in'
          post :sign_out, to: 'users/sessions#sign_out'
          post :refresh_token, to: 'users/sessions#refresh_token'
        end
      end
    end
  end
end
