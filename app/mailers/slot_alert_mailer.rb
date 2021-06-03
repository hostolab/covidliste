class SlotAlertMailer < ApplicationMailer
  helper ApplicationHelper
  default from: "Covidliste <alerte@covidliste.com>"

  def notify
    @alert = params[:alert]
    return if @alert.user.nil?
    return if @alert.user.anonymized_at?

    @alert_token = @alert.token
    @slot = @alert.vmd_slot

    @user = @alert.user
    @passwordless_token = Devise::Passwordless::LoginToken.encode(@user)

    mail(
      to: @alert.user.email,
      subject: "#{@slot.slots_7_days} créneaux sont disponibles près de chez vous."
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
      subject: "Avez-vous pu trouver un rendez-vous de vaccination?"
    )
  end
end
