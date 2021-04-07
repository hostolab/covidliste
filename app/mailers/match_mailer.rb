class MatchMailer < ApplicationMailer
  def match_confirmation_instructions
    @match = params[:match]
    @match_confirmation_token = params[:match_confirmation_token]
    mail(
      to: @match.user.email,
      subject: "Un vaccin est disponible près de chez vous, réservez-le au plus vite !"
    )
  end
end
