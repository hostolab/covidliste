# frozen_string_literal: true

# Run sideway:
# DISABLE_BULLET=true RAILS_ENV=development bin/rails server -b 0.0.0.0 -p 3000

require "fileutils"
require "uri"
require "json"
require "open3"

mailer_locales = ["fr"]
mailer_preview_urls = [
  "http://localhost:3000/rails/mailers/devise_mailer/confirmation_instructions",
  "http://localhost:3000/rails/mailers/devise_mailer/magic_link",
  "http://localhost:3000/rails/mailers/devise_mailer/reset_password_instructions",
  "http://localhost:3000/rails/mailers/devise_mailer/unlock_instructions",

  "http://localhost:3000/rails/mailers/match_mailer/match_confirmation_instructions",
  "http://localhost:3000/rails/mailers/match_mailer/send_anonymisation_notice",
  "http://localhost:3000/rails/mailers/match_mailer/send_confirmed_match_details",

  "http://localhost:3000/rails/mailers/slot_alert_mailer/follow_up",
  "http://localhost:3000/rails/mailers/slot_alert_mailer/notify",

  "http://localhost:3000/rails/mailers/vaccination_center_mailer/confirmed_vaccination_center_onboarding"
]

cwd = "/tmp/rails_mailers"
jobs = []
browser_dir = "#{cwd}/browser"

FileUtils.remove_dir(cwd) if File.exist?(cwd)
FileUtils.mkdir_p(browser_dir)

mailer_locales.each do |mailer_locale|
  mailer_preview_urls.each do |mailer_preview_url|
    uri = URI(mailer_preview_url)
    name = uri.request_uri.split("/").last.to_s
    job_dir = "#{cwd}/screenshots/#{name}"
    FileUtils.mkdir_p(job_dir)
    uri.query = uri.query&.length.to_i > 0 ? "#{uri.query}&locale=#{mailer_locale}" : "locale=#{mailer_locale}"
    url = uri.to_s
    path = "#{job_dir}/#{mailer_locale}.png"
    jobs << {url: url, path: path, name: name, locale: mailer_locale}
  end
end

if jobs.length > 0
  bin = File.expand_path("screenshots_url.js", __dir__)
  data = {cwd: cwd, jobs: jobs.reverse, browser_dir: browser_dir}
  command = "#{bin} '#{data.to_json}'"
  puts command
  stdout, stderr, _status = Open3.capture3(command)
  Rails.logger.debug stdout
  Rails.logger.debug stderr
end
