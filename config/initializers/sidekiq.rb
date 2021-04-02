Sidekiq.configure_client do |config|
  config.redis = { url: (ENV['REDIS_URL'] || 'redis://localhost:6379'), size: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { url: (ENV['REDIS_URL'] || 'redis://localhost:6379'), size: 20 }
end
