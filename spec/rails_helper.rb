ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "spec_helper"
require "capybara/cuprite"
require "rspec/rails"
require "devise"
require "database_cleaner/active_record"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

ActiveRecord::Migration.maintain_test_schema!
DatabaseCleaner[:active_record].strategy = :truncation

Capybara.default_max_wait_time = 10
Capybara.server = :puma
Capybara.javascript_driver = :cuprite

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1440, 900],
    js_errors: false,
    # headless: !(ENV["PREVIEW"] == "true"),
    inspector: (ENV["INSPECTOR"] == "true"),
    process_timeout: 30,
    timeout: 60,
    browser_options: {'no-sandbox': nil}
  )
end

RSpec.configure do |config|
  # Ensure that if we are running js tests, we are using latest webpack assets
  # This will use the defaults of :js and :server_rendering meta tags
  ReactOnRails::TestHelper.configure_rspec_to_compile_assets(config)

  config.prepend_before :each, type: :system do
    driven_by :cuprite
    DatabaseCleaner.allow_remote_database_url = true
    Rails.application.routes.default_url_options = {
      host: Capybara.current_session.server.host,
      port: Capybara.current_session.server.port
    }
    Rails.application.config.action_mailer.default_url_options = \
      Rails.application.routes.default_url_options
  end

  config.include ActiveJob::TestHelper
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ActionView::RecordIdentifier, type: :system # to use the dom_id helper
  config.include SystemSpecHelpers, type: :system
  config.include Warden::Test::Helpers, type: :system
  config.after :each, type: :system do
    Warden.test_reset!
  end

  config.include FactoryBot::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.order = "random"
  config.use_transactional_fixtures = true
  config.include Devise::Test::IntegrationHelpers, type: :request

  config.before :suite do
    Rails.application.load_tasks
    Rake::Task["webpacker:compile"].execute
  end
end

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end
