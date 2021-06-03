class SlotAlertService
  OVERBOOKING_FACTOR = 2
  MAX_DISTANCE_KM = 20

  def initialize(days = 2, threshold = 10)
    @days = days
    @threshold = threshold
  end

  def call
    slots.each do |slot|
      limit = slot.send("slots_#{@days}_days") * OVERBOOKING_FACTOR
      SendAlertsForSlotJob.perform_later({slot_id: slot.id, max_distance: MAX_DISTANCE_KM, limit: limit})
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
