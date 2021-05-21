class SlotAlertMailer < ApplicationMailer
  default from: "Covidliste <dose@covidliste.com>"

  def notify_slot
    @alert = params[:slot_alert]
    return if @alert.user.blank?

    @alert_token = @alert.token
    @slot = @alert.vmd_slot
    mail(
      to: @alert.user.email,
      subject: "Avez vous pu reserver un créneau de vaccination ?"
    )
  end
end
