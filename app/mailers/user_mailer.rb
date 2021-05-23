class UserMailer < ApplicationMailer
  default from: "Covidliste <inscription@covidliste.com>"

  def send_inactive_user_unsubscription_request
    user = User.find(params[:user_id])

    return if user.email.blank?

    mail(
      to: user.email,
      subject: "Attendez-vous toujours une dose de vaccin ?"
    )
  end
end
