class FollowUpSlotAlertsJob < ApplicationJob
  queue_as :mailers

  def perform
    return if Flipper.enabled?(:skip_follow_up_slot_alerts)
    SlotAlert
      .where("created_at between ? and ?", 24.hours.ago, 12.hours.ago)
      .where.not(sent_at: nil)
      .where(follow_up_sent_at: nil).find_each do |alert|
      alert.follow_up
    end
  end
end
