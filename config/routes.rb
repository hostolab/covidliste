require 'sidekiq/web'

Rails.application.routes.draw do


  authenticate :user, lambda(&:super_admin?) do
    mount Blazer::Engine, at: 'admin/blazer'
    mount PgHero::Engine, at: "admin/pghero"
    mount Sidekiq::Web => 'admin/sidekiq'
  end


  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  ## devise
  devise_for :users,
    skip: %i[sessions registrations],
    controllers: {
      confirmations: 'confirmations',
    }

  devise_scope :user do
    get 'login', to: 'devise/sessions#new', as: :new_user_session
    post 'login', to: 'devise/sessions#create', as: :user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  devise_for :partners do
  end

  ####################

  ## users
  resources :users, only: [:create, :new]
  get '/profile' => "users#show", as: :profile
  put '/profile' => "users#update", as: :user
  delete '/profile' => "users#delete", as: :delete_user
  get '/users' => "users#new"

  ## pages
  get '/mentions_legales' => "pages#mentions_legales", as: :mentions_legales
  get '/privacy' => "pages#privacy", as: :privacy
  get '/faq' => "pages#faq", as: :faq
  
  root to: 'users#new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
