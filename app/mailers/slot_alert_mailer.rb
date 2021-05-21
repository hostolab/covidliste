class SlotAlertMailer < ApplicationMailer
  helper ApplicationHelper
  default from: "Covidliste <dose@covidliste.com>"

  def notify_slot
    @alert = params[:alert]
    return if @alert.user.blank?

    @alert_token = @alert.token
    @slot = @alert.vmd_slot
    mail(
      to: @alert.user.email,
      subject: "Des créneaux de vaccination sont disponibles près de chez vous."
    )
  end
end
