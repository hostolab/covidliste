class MatchMailer < ApplicationMailer
  default from: "Covidliste <dose@covidliste.com>"

  def match_confirmation_instructions
    @match = params[:match]
    return if @match.user.blank?

    @match_confirmation_token = @match.match_confirmation_token
    mail(
      to: @match.user.email,
      subject: "Une dose de vaccin est disponible près de chez vous"
    )
  end

  def send_confirmed_match_details
    @match = params[:match]
    return if @match.user.blank?

    mail(
      to: @match.user.email,
      subject: "Covidliste - Votre rendez-vous de vaccination est confirmé"
    )
  end

  def send_anonymisation_notice
    @match = params[:match]
    user_email = params[:user_email] || @match&.user&.email
    return if user_email.blank?

    mail(
      to: user_email,
      subject: "Covidliste - Merci pour votre confiance"
    )
  end
end
