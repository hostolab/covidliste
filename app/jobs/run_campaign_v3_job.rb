class RunCampaignV3Job < ApplicationJob
  SLOW_ADJUSTMENT_FACTOR = 0.25
  LOWER_BOUND_CONVERSION_RATE = 0.002

  queue_as :critical

  # Job that decides users the be matched for a given campaign at a given point in time.
  # This job creates the matches.

  def perform(campaign_id)
    Rails.logger.info("Run RunCampaignV3Job for campaign_id #{campaign_id}")
    campaign = Campaign.find(campaign_id)
    return unless campaign.matching_algo_v3?
    return unless campaign.running?
    return campaign.completed! if campaign.remaining_doses <= 0
    return campaign.completed! if Time.now.utc >= campaign.ends_at

    # compute how many more users we need to match
    projected_conversion = if campaign.matches.count <= 0
      1.0 / campaign.initial_match_count.to_f
    else
      [campaign.projected_confirmations / campaign.matches.count, LOWER_BOUND_CONVERSION_RATE].max
    end
    limit = ((campaign.available_doses.to_f - campaign.projected_confirmations) / projected_conversion * SLOW_ADJUSTMENT_FACTOR).floor

    return if limit <= 0
    users = campaign.reachable_users_query(limit: limit)

    # create matches
    users.each do |user|
      REDIS_LOCK.lock!("create_match_for_user_id_#{user.id}", 2000) do
        Match.create(
          campaign: campaign,
          vaccination_center: campaign.vaccination_center,
          user: user
        )
      end
    rescue Redlock::LockError
      Rails.logger.warning("Could not obtain lock to create match for user_id #{user.id}")
    end
  end
end
