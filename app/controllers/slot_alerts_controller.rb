class SlotAlertsController < ApplicationController
  before_action :set_alert, only: [:show, :update]

  def show
    @alert.update(clicked_at: Time.now) unless @alert.clicked_at
    redirect_to URI.parse(@alert.vmd_slot.url).to_s
  end

  def update
  end

  def set_alert
    @alert = SlotAlert.find_by(token: params[:token])
  end

  def skip_pundit?
    # TODO add a real policy
    true
  end
end
