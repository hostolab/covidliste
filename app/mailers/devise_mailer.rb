class DeviseMailer < Devise::Mailer

  def confirmation_instructions(record, token, opts={})
    mail = super
    mail.subject = "Validez votre inscription sur Covidliste"
    mail
  end

end
