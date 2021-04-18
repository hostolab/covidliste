if Gem::Version.new(Sidekiq::VERSION) < Gem::Version.new("6.1")
  Redis.exists_returns_integer = true
else
  raise "Time to remove Redis.exists_returns_integer: https://github.com/mperham/sidekiq/issues/4591"
end

Sidekiq.configure_client do |config|
  config.redis = {url: (ENV["REDIS_URL"] || "redis://localhost:6379"), size: 1}
end

Sidekiq.configure_server do |config|
  config.redis = {url: (ENV["REDIS_URL"] || "redis://localhost:6379"), size: 20}
end

schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
