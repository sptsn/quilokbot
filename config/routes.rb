Rails.application.routes.draw do
  root to: 'orders#index'

  get 'sign_in' => 'user_sessions#new'
  post 'sign_in' => 'user_sessions#create'
  delete 'sign_out' => 'user_sessions#destroy'

  resources :clients
  resources :orders do
    get 'check' => 'orders#check'
  end
  resources :users
  resources :products


  get 'messages' => 'messages#index'
  post 'messages/send' => 'messages#send_message', as: 'send_message'

  telegram_webhooks TelegramController
end
