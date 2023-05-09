class UserMailer < ApplicationMailer
  default from: "Covidliste <inscription@covidliste.com>"

  MIN_SEND_INTERVAL = 7.days

  def send_inactive_user_unsubscription_request
    @user = User.find(params[:user_id])

    return if @user.email.blank?
    return if @user.last_inactive_user_email_sent_at && @user.last_inactive_user_email_sent_at >= MIN_SEND_INTERVAL.ago

    @user.touch(:last_inactive_user_email_sent_at)

    mail(
      to: @user.email,
      subject: "Attendez-vous toujours une dose de vaccin ?"
    )
  end

  def send_inactive_user_anonymization_notice
    user_email = params[:user_email]

    return if user_email.blank?

    if Flipper.enabled?(:pause_service) or ENV["STATIC_SITE_GEN"]
      mail(
        to: user_email,
        subject: "Nous avons supprimé votre compte Covidliste",
        template_name: "send_inactive_user_anonymization_notice_service_paused"
      )
      return
    end

    mail(
      to: user_email,
      subject: "Nous avons supprimé votre compte Covidliste"
    )
  end
end
