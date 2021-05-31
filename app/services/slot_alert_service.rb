class SlotAlertService
  SLOTS_THRESHOLD = 10
  OVERBOOKING_FACTOR = 1
  MAX_DISTANCE_KM = 20

  def initialize(days = 2)
    @days = days
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
    slots = slots.where("slots_1_days >= ?", SLOTS_THRESHOLD) if @days <= 1
    slots = slots.where("slots_2_days >= ?", SLOTS_THRESHOLD) if @days <= 2
    slots = slots.where("slots_7_days >= ?", SLOTS_THRESHOLD) if @days <= 7
    slots
  end
end
