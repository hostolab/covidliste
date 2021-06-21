class SlotAlertMailer < ApplicationMailer
  default :from => "Covidliste <alerte@covidliste.com>",
          "X-Auto-Response-Suppress" => "OOF"

  include ApplicationHelper
  helper ApplicationHelper

  def notify
    @alert = params[:alert]
    return if @alert.user.nil?
    return if @alert.user.anonymized_at?

    @alert_token = @alert.token
    @slot = @alert.vmd_slot

    @user = @alert.user
    @passwordless_token = Devise::Passwordless::LoginToken.encode(@user)

    distance = distance_delta({lat: @alert.user.lat, lon: @alert.user.lon}, {lat: @slot.latitude, lon: @slot.longitude})
    subject = "#{@slot.slots_7_days} créneaux disponibles à #{distance[:delta_in_words]}, dès #{l(@slot.next_rdv, format: "%A %e %B")}"
    mail(
      to: @alert.user.email,
      subject: subject
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
