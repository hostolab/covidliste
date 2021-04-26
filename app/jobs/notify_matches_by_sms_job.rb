class NotifyMatchesBySmsJob < ApplicationJob
  # Job to decide which matched users to be notified by SMS

  LEAD_TIME_HOURS = 2 # we start sending sms two hours before campaign ends

  def perform(campaign)
    return unless campaign.running?
    return campaign.completed! if campaign.remaining_slots <= 0
    return campaign.completed! if Time.now.utc > campaign.ends_at
    return if campaign.ends_at > LEAD_TIME_HOURS.hours.from_now # do not send any SMS 2 hours before campaign ends
    return if campaign.sms_budget_remaining <= 0

    # get users who should get notified by SMS
    minutes_until_end = ((campaign.ends_at - Time.now.utc) / 60).to_i
    limit = (campaign.sms_budget_remaining / minutes_until_end).to_i
    campaign.matches.pending.email_only.no_email_click.limit(limit).each do |match|
      match.notify_by_sms
    end
  end
end
