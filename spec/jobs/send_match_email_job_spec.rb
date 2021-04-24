require "rails_helper"

describe SendMatchEmailJob do
  let!(:user) { create(:user) }
  let!(:campaign) { create(:campaign) }
  let!(:campaign_batch) { create(:campaign_batch) }
  let!(:match) { create(:match, user: user, campaign_batch: campaign_batch, campaign: campaign) }

  subject { SendMatchEmailJob.new.perform(match) }

  context "match is new" do
    it "sends the email" do
      mail = double(:mail)
      allow(MatchMailer).to receive(:match_confirmation_instructions).with(match).and_return(mail)
      expect(mail).to receive(:deliver_now)
      subject
    end

    it "set expiration" do
      subject
      expect(match.expires_at).to_not be(nil)
    end

    it "set mail_sent_at" do
      subject
      expect(match.mail_sent_at).to_not be(nil)
    end
  end

  context "match is expired" do
    before do
      match.update(expires_at: 10.minutes.ago)
    end
    it "does not send the email" do
      mail = double(:mail)
      allow(MatchMailer).to receive(:match_confirmation_instructions).with(match).and_return(mail)
      expect(mail).to_not receive(:deliver_now)
      subject
    end
  end
end
