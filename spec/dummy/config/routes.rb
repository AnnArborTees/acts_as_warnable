Rails.application.routes.draw do
  devise_for :users
  mount ActsAsWarnable::Engine => '/'
  warning_paths_for :test_objects
end
