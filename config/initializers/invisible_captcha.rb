# frozen_string_literal: true

InvisibleCaptcha.setup do |config|
  config.timestamp_enabled = !Rails.env.test?
  config.honeypots << ["more", "fake", "attribute", "names"]
end
