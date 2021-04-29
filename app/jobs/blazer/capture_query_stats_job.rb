class Blazer::CaptureQueryStatsJob < ApplicationJob
  queue_as :low

  def perform(args)
    PgHero.capture_query_stats
  end
end
