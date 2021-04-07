require "sidekiq/web"

Rails.application.routes.draw do
  namespace :admin do
    get "/" => "home#index"
    # Admins
    authenticate :user, lambda(&:admin?) do
      get "/search" => "search#search", :as => :admin_search
      post "/search" => "search#search"
      resources :vaccination_centers do
        patch :validate, on: :member
      end

      # admin tools
      mount Blazer::Engine, at: "blazer"
      mount Flipper::UI.app(Flipper), at: "/flipper"
    end
  end

  authenticate :user, lambda(&:super_admin?) do
    mount PgHero::Engine, at: "admin/pghero"
    mount Sidekiq::Web => "admin/sidekiq"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  ## devise users
  devise_for :users,
    path_names: {sign_in: "login", sign_out: "logout"},
    skip: %i[sessions registrations],
    controllers: {
      confirmations: "confirmations"
    }

  # TODO FIXME Legacy hardcoced login/logout routes, we should use the routes from devise instead
  devise_scope :user do
    get "login", to: "devise/sessions#new", as: :new_user_session
    post "login", to: "devise/sessions#create", as: :user_session
    delete "logout", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  ## devise partners
  devise_for :partners,
    path_names: {sign_in: "login", sign_out: "logout"},
    skip: %i[registrations],
    controllers: {
      confirmations: "confirmations"
    }

  ####################

  ## users
  resources :users, only: [:create, :new]
  get "/profile" => "users#show", :as => :profile
  put "/profile" => "users#update", :as => :user
  delete "/profile" => "users#delete", :as => :delete_user
  get "/users" => "users#new"

  ## Partners

  resources :partners, only: [:new, :create]
  get "/partenaires/inscription" => "partners#new", :as => :partenaires_inscription_path

  namespace :partners do
    resources :vaccination_centers, only: [:index, :show, :new, :create] do
      resources :campaigns, only: [:new, :create]
    end
    resources :campaigns, only: :show
  end

  ## matches
  resources :matches, only: [:show, :update], param: :token

  ## pages
  get "/mentions_legales" => "pages#mentions_legales", :as => :mentions_legales
  get "/privacy" => "pages#privacy", :as => :privacy
  get "/faq" => "pages#faq", :as => :faq

  ## robots.txt
  get "/robots.txt", to: "pages#robots"

  root to: "users#new"
end
