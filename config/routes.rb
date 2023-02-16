Rails.application.routes.draw do

  get 'password_resets/new'

  get 'password_resets/edit'

  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup', to: 'users#new'
  post '/signup',  to: 'users#create'
  #sessionsリソースの名前付きルートを追加
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  resources :users
  # account_activations resourceのeditへのルーティングのみを生成
  resources :account_activations, only: [:edit]
  # password_resets resourceのnew,create,edit,updateへのルーティングのみを生成
  resources :password_resets,     only: [:new, :create, :edit, :update]
end