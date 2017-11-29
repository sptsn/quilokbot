Rails.application.routes.draw do
  root to: 'home#index'

  get 'sign_in' => 'user_sessions#new'
  post 'sign_in' => 'user_sessions#create'
  delete 'sign_out' => 'user_sessions#destroy'

  resources :residents

  get 'messages/broadcast' => 'messages#broadcast', as: 'broadcast'
  post 'messages/broadcast' => 'messages#send_broadcast', as: 'send_broadcast'
  get 'messages' => 'messages#index'
  post 'messages/send' => 'messages#send_message', as: 'send_message'

  resources :transactions, only: :index

  post "telegram/#{$token}" => 'telegram#recieve'
end
