Rails.application.routes.draw do
  devise_for :users
  mount ActsAsWarnable::Engine => '/'
end
