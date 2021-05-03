require "rails_helper"

describe SendMatchEmailJob do
  let!(:user) { create(:user) }
  let!(:campaign) { create(:campaign) }
  let!(:match) { create(:match, user: user, campaign: campaign) }

  subject { SendMatchEmailJob.new.perform(match.id) }

  context "match is new" do
    it "sends the email" do
      mail = double(:mail)
      allow(MatchMailer).to receive_message_chain("with.match_confirmation_instructions").and_return(mail)
      expect(mail).to receive(:deliver_now)
      subject
    end

    it "sets expiration" do
      subject
      expect(match.reload.expires_at).to_not be(nil)
    end

    it "sets mail_sent_at" do
      subject
      expect(match.reload.mail_sent_at).to_not be(nil)
    end
  end

  context "match is expired" do
    before do
      match.update(expires_at: 10.minutes.ago)
    end
    it "does not send the email" do
      mail = double(:mail)
      allow(MatchMailer).to receive_message_chain("with.match_confirmation_instructions").and_return(mail)
      expect(mail).to_not receive(:deliver_now)
      subject
    end
  end
end
