class SlotAlertService
  def initialize(days = 2, threshold = 20, user_alerting_intensity = nil)
    @days = days
    @threshold = threshold
    @user_alerting_intensity = user_alerting_intensity
  end

  def call
    slots.each do |slot|
      SendAlertsForSlotJob.perform_later({slot_id: slot.id, user_alerting_intensity: @user_alerting_intensity})
    end
  end

  def slots
    slots = VmdSlot
      .where("created_at >= ?", 6.minutes.ago)
      .where("(pfizer is true or moderna is true) and astrazeneca is false")
    slots = slots.where("slots_1_days >= ?", @threshold) if @days <= 1
    slots = slots.where("slots_2_days >= ?", @threshold) if @days <= 2
    slots = slots.where("slots_7_days >= ?", @threshold) if @days <= 7
    slots
  end
end
