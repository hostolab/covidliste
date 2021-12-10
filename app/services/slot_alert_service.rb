class SlotAlertService
  def initialize(threshold = 20, user_alerting_intensity = nil)
    @threshold = threshold
    @user_alerting_intensity = user_alerting_intensity
  end

  def call
    Rails.logger.info("[SlotAlertService] threshold=#{@threshold} user_alerting_intensity=#{user_alerting_intensity}")
    slots.group_by { |x| x.center_id }.each do |center, slots|
      slot = slots.first
      SendAlertsForSlotJob.perform_later({slot_id: slot.id, user_alerting_intensity: @user_alerting_intensity})
    end
  end

  def slots
    slots = VmdSlot
      .where("created_at >= ?", 11.minutes.ago)
      .where("(pfizer is true or moderna is true) and astrazeneca is false")
    slots = slots.where("slots_count >= ?", @threshold)
    slots.order("created_at desc")
  end
end
