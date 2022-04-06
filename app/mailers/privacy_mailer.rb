class PrivacyMailer < ApplicationMailer
  default from: "Covidliste <privacy@covidliste.com>"

  def send_user_anonymization_link_after_user_requested
    @user = User.find(params[:user_id])

    return if @user.email.blank?

    mail(
      to: @user.email,
      subject: "Nous avons bien reçu votre email"
    )
  end
end
