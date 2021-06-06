class RunCampaignJob < ApplicationJob
  queue_as :critical

  SLOW_ADJUSTMENT_FACTOR = 0.25
  FAST_ADJUSTMENT_FACTOR = 0.9
  LOWER_BOUND_CONVERSION_RATE = 0.01
  V3_JOB_MINUTES_CADENCE = 5
  V2_JOB_MINUTES_CADENCE = 2

  # Job that decides users the be matched for a given campaign at a given point in time.
  # This job creates the matches.

  def perform(campaign_id)
    Rails.logger.info("Run RunCampaignJob for campaign_id #{campaign_id}")
    @campaign = Campaign.find(campaign_id)
    return unless @campaign.running?
    return @campaign.completed! if @campaign.remaining_doses <= 0
    return @campaign.completed! if Time.now.utc >= @campaign.ends_at
    return unless should_run?

    # compute how many more users we need to match
    limit = [compute_new_users_to_reach * compute_adjustment_factor, @campaign.email_budget_remaining].min.floor
    return if limit <= 0

    users = @campaign.reachable_users_query(limit: limit)

    # create matches
    users.each do |user|
      REDIS_LOCK.lock!("create_match_for_user_id_#{user.id}", 2000) do
        Match.create(
          campaign: @campaign,
          vaccination_center: @campaign.vaccination_center,
          user: user
        )
      end
    rescue Redlock::LockError
      Rails.logger.warn("Could not obtain lock to create match for user_id #{user.id}")
    end
  end

  def compute_new_users_to_reach
    return (@campaign.target_matches_count - @campaign.matches.pending.alive.count) if @campaign.matching_algo_v2?
    compute_new_users_to_reach_with_v3
  end

  def compute_new_users_to_reach_with_v3
    projected_conversion = if @campaign.matches.count <= 0
      1.0 / @campaign.initial_match_count.to_f
    else
      [@campaign.projected_confirmations / @campaign.matches.count, LOWER_BOUND_CONVERSION_RATE].max
    end
    (@campaign.available_doses.to_f - @campaign.projected_confirmations) / projected_conversion
  end

  def compute_adjustment_factor
    [[@campaign.matches.confirmed.count / 15.0, SLOW_ADJUSTMENT_FACTOR].max, FAST_ADJUSTMENT_FACTOR].min
  end

  def should_run?
    now_minute = DateTime.now.minute
    return true if @campaign.matching_algo_v3? && (now_minute % V3_JOB_MINUTES_CADENCE == 0)
    return true if @campaign.matching_algo_v2? && (now_minute % V2_JOB_MINUTES_CADENCE == 0)
    false
  end
end
