require "rails_helper"

describe SendMatchSmsJob do
  let!(:user) { create(:user) }
  let!(:campaign) { create(:campaign) }
  let!(:match) { create(:match, user: user, campaign: campaign) }
  let!(:twilio_mock) { double }
  let!(:sendinblue_mock) { double }
  let(:sms_url) { "http://localhost:3000/m/#{match.match_confirmation_token}/sms" }
  let(:sms_body_message) do
    "Bonne nouvelle, une dose de vaccin vient de se libérer près de chez vous. Réservez-la vite sur : #{sms_url}"
  end

  before do
    allow_any_instance_of(Sms::MatchMessage).to receive(:cta_url).and_return(sms_url)
  end

  context "Twilio provider" do
    before do
      Flipper.disable(:sendinblue)
      allow(Twilio::REST::Client).to receive(:new).and_return(twilio_mock)
      allow(twilio_mock).to receive_message_chain(:messages, :create).and_return(double(sid: "smsid"))
    end

    subject {
      SendMatchSmsJob.new.perform(match.id)
    }

    context "match is new" do
      it "sends the sms" do
        expect(twilio_mock).to receive_message_chain(:messages, :create).with(from: "Covidliste", to: user.phone_number, body: sms_body_message)
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
        expect(match.reload.sms_provider).to eq("twilio")
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

    context "match user has no phone_number" do
      before do
        user.update_column(:phone_number, nil)
      end

      it "does not send the sms" do
        expect(Twilio::REST::Client).not_to receive(:new)
        subject
      end
    end

    context "match sms has already been sent" do
      before do
        match.update(sms_sent_at: 10.minutes.ago)
      end

      it "does not send the sms" do
        expect(Twilio::REST::Client).not_to receive(:new)
        subject
      end
    end

    context "match has sms_status in error" do
      before do
        match.sms_status_error!
      end

      it "does not send the sms" do
        expect(Twilio::REST::Client).not_to receive(:new)
        subject
      end
    end

    context "Twilio raises an error" do
      it "set the sms_status to error" do
        allow(twilio_mock).to receive_message_chain(:messages, :create).and_raise(Twilio::REST::TwilioError)

        SendMatchSmsJob.new.perform(match.id)
        expect(match.reload.sms_status).to eq("error")
      end
    end
  end

  context "SendInBlue provider" do
    before do
      Flipper.enable(:sendinblue)
      allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sendinblue_mock)
      allow(sendinblue_mock).to receive(:send_transac_sms).and_return(double(message_id: "smsid"))
    end

    subject {
      SendMatchSmsJob.new.perform(match.id)
    }

    context "match is new" do
      it "sends the sms" do
        expect(sendinblue_mock).to receive(:send_transac_sms).with(sender: "Covidliste", recipient: user.phone_number, content: sms_body_message)
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
        expect(match.reload.sms_provider).to eq("sendinblue")
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
        expect(SibApiV3Sdk::TransactionalSMSApi).not_to receive(:new)
        subject
      end
    end

    context "match user has no phone_number" do
      before do
        user.update_column(:phone_number, nil)
      end

      it "does not send the sms" do
        expect(SibApiV3Sdk::TransactionalSMSApi).not_to receive(:new)
        subject
      end
    end

    context "match sms has already been sent" do
      before do
        match.update(sms_sent_at: 10.minutes.ago)
      end

      it "does not send the sms" do
        expect(SibApiV3Sdk::TransactionalSMSApi).not_to receive(:new)
        subject
      end
    end

    context "match has sms_status in error" do
      before do
        match.sms_status_error!
      end

      it "does not send the sms" do
        expect(SibApiV3Sdk::TransactionalSMSApi).not_to receive(:new)
        subject
      end
    end
  end
end
