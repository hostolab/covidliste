class SendSlotAlertFollowUpJob < ApplicationJob
  queue_as :mailers

  def perform(alert_id)
    return if Flipper.enabled?(:pause_service) or ENV["STATIC_SITE_GEN"]
    alert = SlotAlert.find(alert_id)

    return unless alert.sent_at
    return if alert.follow_up_sent_at.present?
    return unless alert.clicked_at
    return if alert.user.nil?
    return if alert.user.anonymized_at?

    # check last follow_up email
    last_follow_up_sent_at = alert.user.slot_alerts.maximum(:follow_up_sent_at)
    return if last_follow_up_sent_at && last_follow_up_sent_at > 24.hours.ago

    SlotAlertMailer.with(alert: alert).follow_up.deliver_now
    alert.update(follow_up_sent_at: Time.now.utc)
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.error(e.message)
    alert.user.anonymize!
  rescue Postmark::ApiInputError => e
    if e.message.start_with?("Invalid 'To' address:")
      Rails.logger.error(e.message)
      alert.user.anonymize!
    else
      raise e
    end
  end
end
