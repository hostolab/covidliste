class Mailer < ApplicationMailer

  def confirmation_email(user_id)
    @user = User.find(user_id)
    subject = 'Inscription sur Covidliste'
    mail(to: @user.email, subject: subject)
  end
  
end
