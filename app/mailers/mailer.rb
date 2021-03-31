class Mailer < ApplicationMailer

  def welcome_user(user_id)
    @user = User.find(user_id)
    subject = 'Inscription sur Covidliste'
    mail(to: @user.email, subject: subject)
  end
  
end
