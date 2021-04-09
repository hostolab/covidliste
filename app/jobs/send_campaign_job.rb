class SendCampaignJob < ApplicationJob
  queue_as :critical

  BATCH_OVERBOOKING_FACTOR = 2 # If there are 10 remaining doses, 20 SMS will be sent
  BATCH_EXPIRE_IN_MINUTES = 6

  STOP_SENDING_BEFORE_CAMPAIGN_ENDS_AT = 10.minutes

  def perform(campaign, partner = nil)
    return unless campaign.running?
    return campaign.completed! if campaign.remaining_slots < 0 || (campaign.ends_at - STOP_SENDING_BEFORE_CAMPAIGN_ENDS_AT) < Time.now.utc

    limit = (campaign.remaining_slots * BATCH_OVERBOOKING_FACTOR).floor

    users = campaign.vaccination_center.reachable_users_query(
      min_age: campaign.min_age,
      max_age: campaign.max_age,
      max_distance_in_meters: campaign.max_distance_in_meters,
      limit: limit
    )

    return campaign.completed! if users.none?

    batch = CampaignBatch.create!(
      campaign: campaign,
      vaccination_center: campaign.vaccination_center,
      size: [limit, users.size].min,
      partner: partner,
      duration_in_minutes: BATCH_EXPIRE_IN_MINUTES
    )

    users.each do |user|
      the_match = Match.create(
        campaign: campaign,
        campaign_batch: batch,
        vaccination_center: campaign.vaccination_center,
        user: user
      )

      SendMatchSmsJob.perform_later(the_match)
      SendMatchEmailJob.perform_later(the_match)
    end

    # Prepare for next campaign batch
    SendCampaignJob.set(wait: BATCH_EXPIRE_IN_MINUTES.minutes + 1.minute).perform_later(campaign, partner)
  end
end
