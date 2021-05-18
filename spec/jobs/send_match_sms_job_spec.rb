require "rails_helper"

describe SendMatchSmsJob do
  let!(:user) { create(:user) }
  let!(:campaign) { create(:campaign) }
  let!(:match) { create(:match, user: user, campaign: campaign) }
  let!(:twilio_mock) { double }
  let!(:sendinblue_mock) { double }

  subject {
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_mock)
    allow(twilio_mock).to receive_message_chain(:messages, :create).and_return(double(sid: "smsid"))

    allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sendinblue_mock)
    allow(sendinblue_mock).to receive(:send_transac_sms).and_return(double(message_id: "smsid"))

    SendMatchSmsJob.new.perform(match.id)
  }

  context "match is new" do
    it "sends the sms" do
      expect(twilio_mock).to receive_message_chain(:messages, :create) # To update when flipping to sendinblue
      subject
    end

    it "sets expiration" do
      subject
      expect(match.reload.expires_at).to_not be(nil)
    end

    it "sets sms_sent_at" do
      subject
      expect(match.reload.sms_sent_at).to_not be(nil)
    end

    it "sets sms_provider" do
      subject
      expect(match.reload.sms_provider).to eq("twilio") # To update when flipping to sendinblue
    end

    it "sets sms_provider_id" do
      subject
      expect(match.reload.sms_provider_id).to eq("smsid")
    end
  end

  context "match is expired" do
    before do
      match.update(expires_at: 10.minutes.ago)
    end

    it "does not send the sms" do
      expect(Twilio::REST::Client).not_to receive(:new)
      subject
    end
  end
end
