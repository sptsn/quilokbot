Rails.application.routes.draw do
  root to: 'pages#index'

  get 'sign_in' => 'user_sessions#new'
  post 'sign_in' => 'user_sessions#create'
  delete 'sign_out' => 'user_sessions#destroy'

  namespace :admin do
    get '/' => 'home#index'
    resources :residents
    get 'messages' => 'messages#index'
    post 'messages/send' => 'messages#send_message', as: 'send_message'
    resources :transactions, only: :index
  end

end
