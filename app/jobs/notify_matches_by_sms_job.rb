class NotifyMatchesBySmsJob < ApplicationJob
  # Job to decide which matched users to be notified by SMS

  LEAD_TIME_HOURS = 2 # we start sending sms two hours before campaign ends

  def perform(campaign)
    Rails.logger.info("Run NotifyMatchesBySmsJob for campaign_id #{campaign.id}")
    return unless campaign.matching_algo_v2?
    return unless campaign.running?
    return if campaign.ends_at > LEAD_TIME_HOURS.hours.from_now # do not send any SMS 2 hours before campaign ends
    return if campaign.sms_budget_remaining <= 0

    # get users who should get notified by SMS
    minutes_until_end = ((campaign.ends_at - Time.now.utc) / 60).to_i
    limit = (campaign.sms_budget_remaining / minutes_until_end).to_i
    campaign.matches.pending.email_only.no_email_click.order(created_at: :asc).limit(limit).each do |match|
      match.notify_by_sms
    end
  end
end
