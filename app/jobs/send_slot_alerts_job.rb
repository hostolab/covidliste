class SendSlotAlertsJob < ApplicationJob
  queue_as :default

  def perform(params)
    return unless params[:days]
    SlotAlertService.new(params[:days],
      params[:threshold],
      params[:user_alerting_intensity]).call
  end
end
