class SendSlotAlertsJob < ApplicationJob
  queue_as :default

  def perform(params)
    return unless params[:days]
    SlotAlertService.new(params[:days]).call
  end
end
