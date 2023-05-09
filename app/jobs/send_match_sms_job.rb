class SendMatchSmsJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :default

  def perform(match_id)
    match = Match.find(match_id)
    return if Flipper.enabled?(:pause_service) or ENV["STATIC_SITE_GEN"]

    return unless match.sms_notification_needed?

    match.set_expiration!

    provider = Flipper.enabled?(:sendinblue, match) ? Sms::SendInBlue : Sms::Twilio
    sms_provider_id = provider.new(Sms::MatchMessage.new(match)).send_message
    match.update(sms_sent_at: Time.now.utc, sms_provider: provider.to_enum_value, sms_provider_id: sms_provider_id, sms_status: Match.sms_statuses[:success])
  rescue Sms::Error => e
    match.sms_status_error!
    log_error(provider, e)
  rescue => e
    log_error(provider, e)
  end

  def log_error(provider, e)
    Rails.logger.info("[SendMatchSmsJob][#{provider}] error #{e.message}")
    if Rails.env.development?
      Rails.logger.debug "[SendMatchSmsJob][#{provider}] error #{e.message}"
    end
  end
end
