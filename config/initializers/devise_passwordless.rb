Rails.configuration.to_prepare do
  Devise::Passwordless::Mailer.layout "mailer"
end
