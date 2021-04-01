Rails.application.routes.draw do
  
  devise_for :users,
    skip: %i[registrations],
    controllers: {
      confirmations: 'confirmations',
    }



  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  resources :users, only: [:create, :new]
  get '/users' => "users#new"
  get '/mentions_legales' => "pages#mentions_legales", as: :mentions_legales
  get '/privacy' => "pages#privacy", as: :privacy

  root to: 'users#new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
