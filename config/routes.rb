require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  draw(:redirects)

  namespace :admin do
    authenticate :user, lambda { |u| u.has_role?(:volunteer) } do
      get "/" => "home#index"

      authenticate :user, lambda { |u| u.has_role?(:supply_member) } do
        # Supply
        resources :campaigns, only: [:index]
        resources :vaccination_centers, only: [:index, :edit, :show, :update, :destroy] do
          authenticate :user, lambda { |u| u.has_role?(:supply_admin) } do
            # Supply Admin
            patch :validate, on: :member
            patch :disable, on: :member
            patch :enable, on: :member
            post :add_partner, on: :member
          end
        end
      end

      authenticate :user, lambda { |u| u.has_role?(:supply_admin) } do
        # Supply admin
        get "/stats" => "stats#stats"
        post "/stats" => "stats#stats"
      end

      authenticate :user, lambda { |u| u.has_role?(:support_member) } do
        # Support
        resources :users, only: [:index, :destroy] do
          post :resend_confirmation, on: :member
        end
      end

      authenticate :user, lambda { |u| u.has_role?(:ds_admin) } do
        # DataScience admin
        mount Blazer::Engine, at: "/blazer"
      end

      authenticate :user, lambda { |u| u.has_role?(:admin) } do
        # Core Team
        resources :power_users, only: [:index]
      end

      authenticate :user, lambda { |u| u.has_role?(:super_admin) } do
        # Super Admin
        resources :power_users, only: [:create, :update, :destroy]
        mount PgHero::Engine, at: "/pghero"
        mount Sidekiq::Web => "/sidekiq"
        mount Flipper::UI.app(Flipper), at: "/flipper", as: :flipper_ui
      end
    end
  end

  namespace :api do
    resources :power_users, only: [:index]
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  ## devise users
  devise_for :users,
    path_names: {sign_in: "login", sign_out: "logout"},
    skip: %i[registrations],
    controllers: {
      sessions: "devise/passwordless/sessions",
      confirmations: "confirmations"
    }

  # TODO FIXME Legacy hardcoced login/logout routes, we should use the routes from devise instead
  devise_scope :user do
    get "/users/magic_link", to: "devise/passwordless/magic_links#show", as: "users_magic_link"
  end

  ## devise partners
  devise_for :partners,
    path_names: {sign_in: "login", sign_out: "logout"},
    skip: %i[registrations],
    controllers: {
      confirmations: "partners/confirmations",
      passwords: "partners/passwords",
      sessions: "partners/sessions",
      unlocks: "partners/unlocks",
      omniauth_callbacks: "partners/omniauth_callbacks"
    }

  ####################

  ## users
  resources :users, only: [:create, :new, :index] do
    collection do
      resource :profile, controller: "users", only: [:show, :update, :destroy] do
        get :confirm_destroy
      end
    end
  end

  ## Partners
  resources :partners, only: [:new, :create]
  resource :partners, only: [:show, :update, :destroy]
  get "/pro" => "pages#landing_page_pro", :as => :landing_page_pro
  get "/partenaires", to: redirect("/pro", status: 302)
  get "/partenaires/inscription" => "partners#new", :as => :partenaires_inscription
  get "/partenaires/faq" => "pages#faq_pro", :as => :partenaires_faq

  namespace :partners do
    resources :vaccination_centers, only: [:index, :show, :new, :create, :update] do
      resources :campaigns, only: [:new, :create] do
        post :simulate_reach, on: :collection
      end
    end
    resources :campaigns, only: [:show, :update]
    resources :partner_external_accounts, only: [:destroy]
  end

  # slot alerts
  get "/s/:token" => "slot_alerts#show", :as => :slot_alert
  patch "/s/:token" => "slot_alerts#update"

  # Matches
  get "/m/:match_confirmation_token(/:source)" => "matches#show", :as => :match
  patch "/m/:match_confirmation_token(/:source)" => "matches#update"
  delete "/m/:match_confirmation_token(/:source)" => "matches#destroy"
  get "/matches/:match_confirmation_token(/:source)" => "matches#show" # temporary to make sure existing matches work

  ## Pages
  get "/vaccination_centers/geojson.json" => "vaccination_centers#geojson", :as => :vaccination_centers_geojson
  get "/vaccination_centers/missing_users/geojson.json" => "vaccination_centers#missing_users_geojson", :as => :vaccination_centers_missing_users_geojson
  get "/carte" => "pages#carte", :as => :carte
  get "/donateurs" => "pages#donateurs", :as => :donateurs
  get "/sponsors" => "pages#sponsors", :as => :sponsors
  get "/benevoles" => "pages#benevoles", :as => :benevoles
  get "/contact" => "pages#contact", :as => :contact
  get "/algorithme" => "pages#algorithme", :as => :algorithme
  get "/presse", to: redirect("https://blog.covidliste.com/presse/home", status: 302), as: :presse
  get "/faq" => "pages#faq", :as => :faq

  ## Pages from frozen_records/static_pages.yml
  get "/mentions_legales" => "pages#mentions_legales", :as => :mentions_legales
  get "/cgu_volontaires" => "pages#cgu_volontaires", :as => :cgu_volontaires
  get "/cgu_pro" => "pages#cgu_pro", :as => :cgu_pro
  get "/privacy_volontaires" => "pages#privacy_volontaires", :as => :privacy_volontaires
  get "/privacy_pro" => "pages#privacy_pro", :as => :privacy_pro
  get "/cookies" => "pages#cookies", :as => :cookies

  ## Redirections
  get "/privacy" => redirect("/privacy_volontaires") # 301

  ## robots.txt
  get "/robots.txt", to: "pages#robots"

  root to: "users#new"
end
