class SendSlotAlertsJob < ApplicationJob
  queue_as :critical

  def perform(params)
    return unless params[:days]
    SlotAlertService.new(params[:days],
      params[:threshold],
      params[:user_alerting_intensity]).call
  end
end
