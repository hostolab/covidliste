require "rails_helper"

describe SendConfirmedMatchEmailJob do
  let!(:user) { create(:user) }
  let!(:campaign) { create(:campaign) }
  let!(:match) { create(:match, user: user, campaign: campaign) }
  match.confirm!

  subject { SendConfirmedMatchEmailJob.new.perform(match.id) }

  context "match is confirmed by a user" do
    it "sends the email" do
      mail = double(:mail)
      allow(MatchMailer).to receive_message_chain("with.send_confirmed_match_details").and_return(mail)
      expect(mail).to receive(:deliver_now)
      subject
    end

    it "set confirmed_mail_sent_at" do
      subject
      expect(match.reload.confirmed_mail_sent_at).to_not be(nil)
    end
  end
end
