class DeviseMailer < Devise::Mailer

  default from: 'Covidliste <hello@covidliste.com>', reply_to: 'no-reply@covidliste.com'

  def confirmation_instructions(record, token, opts={})
    mail = super
    mail.subject = "Validez votre inscription sur Covidliste"
    mail
  end

end
