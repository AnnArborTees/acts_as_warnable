ActsAsWarnable::Engine.routes.draw do
  resources :warnings
  resources :warning_emails
end
