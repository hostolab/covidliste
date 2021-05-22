class SlotAlertMailer < ApplicationMailer
  helper ApplicationHelper
  default from: "Covidliste <dose@covidliste.com>"

  def notify
    @alert = params[:alert]
    return if @alert.user.nil?
    return if @alert.user.anonymized_at?

    @alert_token = @alert.token
    @slot = @alert.vmd_slot
    mail(
      to: @alert.user.email,
      subject: "Des créneaux de vaccination sont disponibles près de chez vous."
    )
  end

  def follow_up
    @alert = params[:alert]
    return if @alert.user.nil?
    return if @alert.user.anonymized_at?

    @alert_token = @alert.token
    @slot = @alert.vmd_slot

    mail(
      to: @alert.user.email,
      subject: "Avez-vous pu trouver un créneau de vaccination?"
    )
  end
end
