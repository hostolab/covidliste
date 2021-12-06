require "rails_helper"

describe SendUserAnonymizationLinkAfterUserRequestedJob do
  let!(:user) { create(:user) }

  subject { SendUserAnonymizationLinkAfterUserRequestedJob.new.perform(user.id) }

  context "user is not anonymized" do
    before do
      user.update(anonymized_at: nil)
    end
    it "sends the email" do
      mail = double(:mail)
      allow(UserMailer).to receive_message_chain("with.send_user_anonymization_link_after_user_requested").and_return(mail)
      expect(mail).to receive(:deliver_now)
      subject
    end
  end

  context "user is already anonymized" do
    before do
      user.update(anonymized_at: Time.now.utc)
    end
    it "does not send the email" do
      mail = double(:mail)
      allow(UserMailer).to receive_message_chain("with.send_user_anonymization_link_after_user_requested").and_return(mail)
      expect(mail).not_to receive(:deliver_now)
      subject
    end
  end
end
