class MatchMailer < ApplicationMailer
  default from: "Covidliste <dose@covidliste.com>"

  def match_confirmation_instructions
    @match = params[:match]
    return if @match.user.blank?

    @match_confirmation_token = @match.match_confirmation_token
    mail(
      to: @match.user.email,
      subject: "Une dose de vaccin est disponible, réservez-la vite."
    )
  end

  def send_anonymisation_notice
    @match = params[:match]
    user_email = params[:user_email] || @match&.user&.email
    return if user_email.blank?

    mail(
      to: user_email,
      subject: "Merci de nous avoir fait confiance !"
    )
  end
end
