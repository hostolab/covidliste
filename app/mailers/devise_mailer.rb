class DeviseMailer < Devise::Mailer
  default :from => "Covidliste <inscription@covidliste.com>",
          "X-Auto-Response-Suppress" => "OOF"
  layout "mailer"
end
