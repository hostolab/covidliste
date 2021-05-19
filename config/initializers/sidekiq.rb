if Gem::Version.new(Sidekiq::VERSION) < Gem::Version.new("6.1")
  Redis.exists_returns_integer = true
else
  raise "Time to remove Redis.exists_returns_integer: https://github.com/mperham/sidekiq/issues/4591"
end

Sidekiq.configure_client do |config|
  config.redis = {url: (ENV["REDIS_URL"] || "redis://localhost:6379")}
end

Sidekiq.configure_server do |config|
  config.redis = {url: (ENV["REDIS_URL"] || "redis://localhost:6379")}
end

Marginalia::SidekiqInstrumentation.enable!

if Sidekiq.server?
  schedule_default = if Rails.env.production? || Rails.env.staging?
    "config/schedule.yml"
  else
    "config/schedule.dev.yml"
  end
  schedule_file = ENV.fetch("SIDEKIQ_SCHEDULE", schedule_default)
  if schedule_file.present? && File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end
