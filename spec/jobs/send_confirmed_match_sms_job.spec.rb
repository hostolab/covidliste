require "rails_helper"

describe SendConfirmedMatchSmsJob do
  let!(:user) { create(:user) }
  let!(:campaign) { create(:campaign) }
  let!(:match) { create(:match, user: user, campaign: campaign) }
  let!(:twilio_mock) { double }
  let!(:sendinblue_mock) { double }

  match.confirm!

  subject {
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_mock)
    allow(twilio_mock).to receive_message_chain(:messages, :create).and_return(double(sid: "smsid"))

    allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sendinblue_mock)
    allow(sendinblue_mock).to receive(:send_transac_sms).and_return(double(message_id: "smsid"))

    SendConfirmedMatchSmsJob.new.perform(match.id)
  }

  context "match is confirmed by a user" do
    it "sends the sms" do
      expect(twilio_mock).to receive_message_chain(:messages, :create) # To update when flipping to sendinblue
      subject
    end

    it "set confirmed_sms_sent_at" do
      subject
      expect(match.reload.confirmed_sms_sent_at).to_not be(nil)
    end
  end
end
