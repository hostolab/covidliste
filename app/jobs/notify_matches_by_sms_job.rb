class NotifyMatchesBySmsJob < ApplicationJob
  # Job to decide which matched users to be notified by SMS

  LEAD_TIME = 90.minutes # we start sending sms X minutes before campaign ends

  def perform(campaign_id)
    Rails.logger.info("Run NotifyMatchesBySmsJob for campaign_id #{campaign_id}")
    campaign = Campaign.find(campaign_id)
    return if Flipper.enabled?(:pause_service)
    return unless campaign.running?
    return if campaign.ends_at > LEAD_TIME.from_now # do not send any SMS X minutes before campaign ends
    return if campaign.sms_budget_remaining <= 0

    # get users who should get notified by SMS
    minutes_until_end = ((campaign.ends_at - Time.now.utc) / 60).to_i
    return if minutes_until_end <= 0
    limit = (campaign.sms_budget_remaining / minutes_until_end).to_i
    campaign.matches.pending.email_only.no_email_click.order(created_at: :asc).limit(limit).each do |match|
      match.notify_by_sms
    end
  end
end
