class DeviseMailer < Devise::Mailer
  def reset_password_instructions(record, token, opts={})
    mail = super
    mail.subject = "Validez votre inscription sur Covidliste"
    mail
  end
end
