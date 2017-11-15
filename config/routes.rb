Rails.application.routes.draw do
  root to: 'pages#index'

  get 'sign_in' => 'user_sessions#new'
  post 'sign_in' => 'user_sessions#create'
  delete 'sign_out' => 'user_sessions#destroy'

  namespace :admin do
    get '/' => 'home#index'
    resources :residents, except: [:index]
  end

end
