redis_url = (ENV["REDIS_URL"] || "redis://localhost:6379")
REDIS_LOCK = Redlock::Client.new([redis_url])
if Rails.env.test?
  require "redlock/testing"
  Redlock::Client.testing_mode = :bypass
end
