ActsAsWarnable::Engine.routes.draw do
  resources :warnings, only: [:index, :show, :create, :destroy]
end
