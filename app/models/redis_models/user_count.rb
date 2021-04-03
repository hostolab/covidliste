module RedisModels
  class UserCount
    class << self

      REDIS_KEY = 'user_count_key'

      def current
        $redis.get(REDIS_KEY).to_i
      end

      def update(value)
        $redis.set(REDIS_KEY, value)
      end

      def increment
        update(current + 1)
      end

      def compute_count
        update(User.all.size)
      end
    end
  end
end
