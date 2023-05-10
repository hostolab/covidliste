class ApplicationMailbox < ActionMailbox::Base
  PRIVACY_REGEX = /privacy@covidliste.com/i

  # route for incoming emails on that email to PrivacyMailbox
  routing PRIVACY_REGEX => :privacy
end
