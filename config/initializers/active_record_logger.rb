# frozen_string_literal: true

# This event happens quite a lot and fans out to ExplainSubscriber
# and Logger, this cuts out 2 method calls that every time we run SQL
#
# In production we do not care about Explain or Logging SQL statements
# at this level
#
# Micro bench shows for `User.first` this takes us from 3.3k/s to 3.5k/s
if Rails.env.production?
  ActiveSupport::Notifications.notifier.unsubscribe("sql.active_record")
end

# ActiveRecord logging is great because it shows every SQL query that hits your database.
# You can easily pinpoint slow, useless, or duplicate queries and optimize your code accordingly.
# Thanks to SQL caching, ActiveRecord will hit the database only once per needed query.
# But it will still log them twice, prefixed with CACHE on the second time.
# These last two lines aren’t actual queries. They don’t hit the database, always take 0.0ms, and pollute your logs.
# To fix this, we create a logger that ignores messages containing "CACHE"
# There you go, no more CACHE logs. Happy SQL optimizing!
if Rails.env.development?
  class CacheFreeLogger < ::Logger
    def debug(message, *args, &block)
      super unless message.include? "CACHE "
    end
  end
  # ActiveRecord::Base.logger = nil # Hide completely all logs SQL
  ActiveRecord::Base.logger = ActiveSupport::TaggedLogging.new(CacheFreeLogger.new(STDOUT))
end
