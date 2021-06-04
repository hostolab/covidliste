class SendAlertsForSlotJob < ApplicationJob
  queue_as :default

  def perform(params)
    return unless params[:slot_id]
    slot = VmdSlot.find(params[:slot_id])
    slot.send_alerts
  end
end
