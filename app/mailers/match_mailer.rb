class MatchMailer < ApplicationMailer
  def match_confirmation_instructions
    @match = params[:match]
    return if @match.user.blank?

    @match_confirmation_token = @match.match_confirmation_token
    mail(
      to: @match.user.email,
      subject: "Un vaccin est disponible près de chez vous, réservez-le au plus vite !"
    )
  end

  def send_anonymisation_notice
    @match = params[:match]
    @user = params[:user] || @match.user
    return if @user.blank?

    mail(
      to: @user.email,
      subject: "Merci de nous avoir fait confiance !"
    )
  end
end
