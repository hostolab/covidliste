class SendSlotAlertEmailJob < ApplicationJob
  queue_as :mailers

  def perform(alert_id)
    alert = SlotAlert.find(alert_id)

    return if alert.sent_at.present?
    SlotAlertMailer.with(alert: alert).notify_slot.deliver_now
    alert.update(sent_at: Time.now.utc)
  end
end
