# frozen_string_literal: true

class SlotAlertMailerPreview < ActionMailer::Preview
  def notify_slot
    alert = FactoryBot.create(:slot_alert)
    SlotAlertMailer.with(alert: alert).notify_slot.deliver_now
  end
end
