Rails.application.routes.draw do
  root "dashboards#index"

  get '/auth/poizon', to: 'auth#redirect_to_poizon', as: :auth_poizon
  get '/auth/poizon/callback', to: 'auth#callback'
  delete '/auth/poizon', to: 'auth#disconnect', as: :disconnect_poizon

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end