class SendCampaignJob < ApplicationJob
  queue_as :critical

  BATCH_OVERBOOKING_FACTOR = 2 # If there are 10 remaining doses, 10 * 2 SMS will be sent
  BATCH_EXPIRE_IN_MINUTES = 7

  def perform(campaign, partner = nil)
    return if campaign.remaining_slots.zero?

    batch = CampaignBatch.create!(
      campaign: campaign,
      vaccination_center: campaign.vaccination_center,
      size: campaign.remaining_slots * BATCH_OVERBOOKING_FACTOR,
      partner: partner,
      duration_in_minutes: BATCH_EXPIRE_IN_MINUTES
    )

    users = batch.vaccination_center.reachable_users_query(
      min_age: campaign.min_age,
      max_age: campaign.max_age,
      max_distance_in_meters: campaign.max_distance_in_meters,
      limit: batch.size
    )

    return if users.none?

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
    SendCampaignJob.set(wait: BATCH_EXPIRE_IN_MINUTES + 1.minute).perform_later(campaign, partner)
  end
end
