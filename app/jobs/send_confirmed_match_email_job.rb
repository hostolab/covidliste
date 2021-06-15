class SendConfirmedMatchEmailJob < ApplicationJob
  queue_as :mailers

  def perform(match_id)
    match = Match.find(match_id)

    return if match.confirmed_mail_sent_at.present?
    MatchMailer.with(match: match).send_confirmed_match_details.deliver_now
    match.update(confirmed_mail_sent_at: Time.now.utc)
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
