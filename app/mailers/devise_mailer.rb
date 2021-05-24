class DeviseMailer < Devise::Mailer
  default :from => "Covidliste <inscription@covidliste.com>", "X-Auto-Response-Suppress" => "OOF"
  layout "mailer"

  def confirmation_instructions(record, token, opts = {})
    super do |format|
      format.mjml
    end
  end

  def reset_password_instructions(record, token, opts = {})
    super do |format|
      format.mjml
    end
  end

  def unlock_instructions(record, token, opts = {})
    super do |format|
      format.mjml
    end
  end

  def magic_link(record, token, remember_me, opts = {})
    super do |format|
      format.mjml
    end
  end
end
