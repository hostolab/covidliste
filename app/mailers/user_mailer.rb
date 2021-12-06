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

    mail(
      to: user_email,
      subject: "Nous avons supprimé votre compte Covidliste"
    )
  end

  def send_user_anonymization_link_after_user_requested
    @user = User.find(params[:user_id])

    return if @user.email.blank?

    mail(
      to: @user.email,
      subject: "Nous avons bien reçu votre email"
    )
  end
end
