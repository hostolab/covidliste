class SendMatchEmailJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on# TODO: # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :default

  def perform(match_id)
    match = Match.find(match_id)
    return if Flipper.enabled?(:pause_service) or ENV["STATIC_SITE_GEN"]

    return if match.mail_sent_at.present? || match.expired? || match.refused?
    return if match.user.nil?
    return if match.user.anonymized_at?
    match.set_expiration!
    MatchMailer.with(match: match).match_confirmation_instructions.deliver_now
    match.update(mail_sent_at: Time.now.utc)
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.error(e.message)
    match.user.anonymize!
  rescue Postmark::ApiInputError => e
    if e.message.start_with?("Invalid 'To' address:")
      Rails.logger.error(e.message)
      match.user.anonymize!
    else
      raise e
    end
  end
end
