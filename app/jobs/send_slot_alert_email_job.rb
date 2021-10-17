class SendSlotAlertEmailJob < ApplicationJob
  queue_as :mailers

  def perform(alert_id)
    return if Flipper.enabled?(:pause_service)
    alert = SlotAlert.find(alert_id)
    return if alert.user.nil?
    return if alert.user.anonymized_at?
    return if alert.sent_at.present?

    SlotAlertMailer.with(alert: alert).notify.deliver_now
    alert.update(sent_at: Time.now.utc)
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
