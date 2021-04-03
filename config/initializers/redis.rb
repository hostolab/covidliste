require 'yaml'

class RedisInit
  # @return [Redis] A redis instance
  def self.build_redis_client
    configs = {url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }}
    Redis.new(configs).extend(ProtectFromHumanErrors)
  end

  module ProtectFromHumanErrors
    def flushall(force: false)
      if Rails.env.development? || Rails.env.test? || force
        super()
      else
        raise 'You are in PRODUCTION environment! To flushall, use flushall(force: true)'
      end
    end

    def flushdb(force: false)
      if Rails.env.development? || Rails.env.test? || force
        super()
      else
        raise 'You are in PRODUCTION environment! To flushdb, use flushdb(force: true)'
      end
    end
  end
end

$redis        = RedisInit.build_redis_client
Redis.current = $redis # required for redis-objects
