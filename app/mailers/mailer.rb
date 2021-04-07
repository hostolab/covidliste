class Mailer < ApplicationMailer
  def match_confirmation_instructions
    @match = params[:match]
    @token = params[:token]
    mail(
      to: @match.user.email,
      subject: 'Un vaccin est disponible près de chez vous, réservez-le au plus vite !'
    )
  end
end
