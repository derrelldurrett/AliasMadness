Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'static_pages#home'
  get 'login', to: 'sessions#login'

  resources :users do
    get :login
  end
  resources :brackets, only: [:update, :show]

  get 'scenarios', to: 'brackets#scenarios'
  put 'lock_names', to: 'teams#lock_names'
  put 'lock_players_brackets', to: 'brackets#lock_brackets'

  mount ActionCable.server => '/cable'

  namespace :admin do
    resources :messages, only: [:create, :new]
  end
end
