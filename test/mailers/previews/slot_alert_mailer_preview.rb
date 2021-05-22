# frozen_string_literal: true

class SlotAlertMailerPreview < ActionMailer::Preview
  def notify
    alert = FactoryBot.create(:slot_alert)
    SlotAlertMailer.with(alert: alert).notify.deliver_now
  end

  def follow_up
    alert = FactoryBot.create(:slot_alert)
    SlotAlertMailer.with(alert: alert).follow_up.deliver_now
  end
end
