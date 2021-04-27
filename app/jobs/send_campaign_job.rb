class SendCampaignJob < ApplicationJob
  queue_as :critical

  STOP_SENDING_BEFORE_CAMPAIGN_ENDS_AT = 10.minutes

  def perform(campaign_id)
    campaign = Campaign.find_by(id: campaign_id)
    return if campaign.blank?
    return if campaign.matching_algo_v2?
    return unless campaign.running?
    return campaign.completed! if campaign.remaining_doses <= 0 || (campaign.ends_at - STOP_SENDING_BEFORE_CAMPAIGN_ENDS_AT) < Time.now.utc

    limit = (campaign.remaining_doses * Vaccine.overbooking_factor(campaign.vaccine_type)).floor
    users = campaign.reachable_users_query(limit: limit)

    return campaign.completed! if users.none?

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

    # Prepare for next campaign batch
    SendCampaignJob.set(wait: Match::EXPIRE_IN_MINUTES.minutes + 1.minute).perform_later(campaign.id)
  end
end
