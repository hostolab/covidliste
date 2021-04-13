require_relative "boot"

require "rails/all"
require "csv"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module Covidliste
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :rspec, fixture: false
      generate.fixture_replacement :factory_bot, dir: "spec/factories"
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.i18n.default_locale = :fr

    config.active_job.queue_adapter = :sidekiq

    config.after_initialize do |app|
      app.routes.default_url_options = app.config.action_mailer.default_url_options
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Europe/Paris"

    config.assets.version = "1.0"
    config.assets.paths << Rails.root.join("node_modules")

    # Disabling this feature because some people are blocking referer headers for privacy
    config.action_controller.forgery_protection_origin_check = false

    config.action_dispatch.cookies_serializer = :json

    config.filter_parameters +=
      [:passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :email,
       :firstname, :lastname, :phone_number, :address]

    config.content_security_policy_nonce_generator =
      -> (request) { SecureRandom.base64(16) }
    config.content_security_policy_nonce_directives = %w[script-src]
  end
end
