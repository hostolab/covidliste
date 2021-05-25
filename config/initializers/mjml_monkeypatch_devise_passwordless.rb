module MjmlMonkeyPatchDevisePassswordLessMailer
  def magic_link(record, token, remember_me, opts = {})
    super do |format|
      format.mjml
    end
  end
end

Rails.configuration.to_prepare do
  Devise::Passwordless::Mailer.class_eval do
    layout "mailer"
  end
end

Devise::Passwordless::Mailer.prepend MjmlMonkeyPatchDevisePassswordLessMailer
