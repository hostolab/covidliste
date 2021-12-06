class PrivacyMailbox < ApplicationMailbox
  before_processing :find_user

  def process
    return if !@user ||@user.anonymized_at?

    puts "[PrivacyMailbox] Auto-sending an email notice to ##{@user.id} with a destroy link"
    SendUserAnonymizationLinkAfterUserRequestedJob.perform_later(@user.id)
  end

  private

  def find_user
    @user ||= User.find_by(email: mail.from)
  end
end
