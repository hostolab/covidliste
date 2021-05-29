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

    config.action_dispatch.default_headers = {
      "Permissions-Policy" => "interest-cohort=()"
    }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Europe/Paris"
    # config.eager_load_paths << Rails.root.join("extras")
    config.x.covidliste = config_for(:covidliste)
  end
end
