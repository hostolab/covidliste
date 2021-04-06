source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem 'autoprefixer-rails'
gem 'font-awesome-sass'
gem 'simple_form'
gem "haml-rails", "~> 2.0"
gem 'bootstrap', '~> 5.0.0.beta2'
gem 'letter_opener', '~> 1.7'
gem 'letter_opener_web', '~> 1.4'
gem 'devise'
gem 'rolify'
gem 'blazer'
gem 'pghero'
gem 'pg_query', '>= 0.9.0'
gem 'sidekiq'
gem 'geocoder'
gem 'blind_index'
gem 'lockbox'
gem 'appsignal'

# Email mx validation github.com/hallelujah/valid_email
gem 'valid_email'
gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
gem 'httparty'

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'dotenv-rails', '2.7.6'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'cuprite'
  gem 'selenium-webdriver'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 4.0.0'
  gem 'rspec-sidekiq'
  gem 'database_cleaner-active_record'
  gem 'webmock'
  gem 'spring'
  gem "spring-commands-rspec", "~> 1.0"
  gem 'rspec_junit_formatter'
end

# Windows does not include zone
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "twilio-ruby", "~> 5.50"

