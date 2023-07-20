Rails.application.routes.draw do
  require 'sidekiq/web'
  resources :inventories
  resources :imports
  resources :smartsheets, only: [:index]
  get 'send_to_shopify', to: 'imports#send_to_shopify'
  
  mount Sidekiq::Web => '/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "smartsheets#index"
end
