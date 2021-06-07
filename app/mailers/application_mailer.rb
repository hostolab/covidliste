class ApplicationMailer < ActionMailer::Base
  default :from => "Covidliste <inscription@covidliste.com>",
          "X-Auto-Response-Suppress" => "OOF"
  layout "mailer"

  def mail(headers)
    super(headers) do |format|
      format.mjml
    end
  end
end
