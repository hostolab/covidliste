class SendSlotAlertsJob < ApplicationJob
  queue_as :default

  def perform(params)
    return unless params[:days]
    SlotAlertService.new(params[:days], params[:threshold], user_alerting_intensity: params[:user_alerting_intensity]).call
  end
end
