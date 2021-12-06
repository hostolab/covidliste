class SendUserAnonymizationLinkAfterUserRequestedJob < ApplicationJob
  queue_as :mailers

  def perform(user_id)
    user = User.find(user_id)

    return if user.anonymized_at?
    UserMailer.with(user_id: user.id).send_user_anonymization_link_after_user_requested.deliver_now
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.error(e.message)
    user.anonymize!
  rescue Postmark::ApiInputError => e
    if e.message.start_with?("Invalid 'To' address:")
      Rails.logger.error(e.message)
      user.anonymize!
    else
      raise e
    end
  end
end
