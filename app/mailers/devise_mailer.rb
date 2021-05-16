class DeviseMailer < Devise::Mailer
  default :from => "Covidliste <inscription@covidliste.com>", "X-Auto-Response-Suppress" => "OOF"

  def confirmation_instructions(record, token, opts = {})
    mail = super
    mail.subject = "Covidliste - Valider votre inscription"
    mail
  end
end
