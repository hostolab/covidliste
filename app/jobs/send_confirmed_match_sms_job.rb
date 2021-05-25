class SendConfirmedMatchSmsJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :mailers

  def perform(match_id)
    match = Match.find(match_id)

    return unless match.sms_confirmed_notification_needed?

    provider = Flipper.enabled?(:sendinblue, match) ? Sms::SendInBlue : Sms::Twilio

    sms_provider_id = provider.new(Sms::ConfirmedMessage.new(match)).send

    match.update(confirmed_sms_sent_at: Time.now.utc, conf_sms_provider: provider.to_enum_value, conf_sms_provider_id: sms_provider_id, conf_sms_status: Match.conf_sms_statuses[:success])
  rescue Sms::Error => e
    match.conf_sms_status_error!
    log_error(provider, e)
  rescue => e
    log_error(provider, e)
  end

  def log_error(provider, e)
    Rails.logger.info("[SendConfirmedMatchSmsJob][#{provider}] error #{e.message}")
    if Rails.env.development?
      puts "[SendConfirmedMatchSmsJob][#{provider}] error #{e.message}"
    end
  end
end
