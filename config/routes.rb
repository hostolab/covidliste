Rails.application.routes.draw do
  
  devise_for :users,
    skip: %i[sessions registrations]

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  resources :users, only: [:create, :new]
  get '/users' => "users#new"
  root to: 'users#new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
