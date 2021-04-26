class RunCampaignJob < ApplicationJob
  queue_as :critical

  # Job that decides users the be matched for a given campaign at a given point in time.
  # This job creates the matches.

  def perform(campaign)
    Rails.logger.info("Run RunCampaignJob for campaign_id #{campaign.id}")
    return unless campaign.running?
    return campaign.completed! if campaign.remaining_doses <= 0
    return campaign.completed! if Time.now.utc >= campaign.ends_at

    # compute how many more users we need to match
    limit = campaign.target_matches_count - campaign.matches.pending.alive.count
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
