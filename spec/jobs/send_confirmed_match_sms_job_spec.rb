require "rails_helper"

describe SendConfirmedMatchSmsJob do
  let!(:user) { create(:user, phone_number: "+33601020304") }
  let!(:campaign) { create(:campaign, starts_at: Time.zone.parse("2021-05-23 12:50"), ends_at: Time.zone.parse("2021-05-23 13:15")) }
  let!(:vaccination_center) { create(:vaccination_center, name: "Bicycle rights blue bottle typewriter copper mug, chicharrones helvetica man bun direct trade salvia literally. Pinterest farm-to-table adaptogen synth meditation chia 8-bit. Everyday carry iceland meggings semiotics direct trade, adaptogen gochujang. Hammock sartorial thundercats hoodie try-hard shaman butcher skateboard squid.", city: "Paris") }
  let!(:match) { create(:match, user: user, campaign: campaign, vaccination_center: vaccination_center) }
  let!(:twilio_mock) { double }
  let!(:sendinblue_mock) { double }
  let(:sms_url) { "http://localhost:3000/m/#{match.match_confirmation_token}/c_sms" }
  let(:expected_sms_body_message) do
    "RDV confirmé dim 23/05 12h50 - 13h15\n"\
    "Bicycle rights blue bottle typewriter copp..., Paris\n"\
    "Plus d'info sur #{sms_url}"
  end

  before do
    match.confirm!
    allow_any_instance_of(Sms::ConfirmedMessage).to receive(:cta_url).and_return(sms_url)
  end

  context "Twilio provider" do
    before do
      Flipper.disable(:sendinblue)
      allow(Twilio::REST::Client).to receive(:new).and_return(twilio_mock)
      allow(twilio_mock).to receive_message_chain(:messages, :create).and_return(double(sid: "smsid"))
    end

    subject {
      SendConfirmedMatchSmsJob.new.perform(match.id)
    }

    context "match is confirmed" do
      it "sends the confirm sms" do
        expect(twilio_mock).to receive_message_chain(:messages, :create).with(from: "Covidliste", to: user.phone_number, body: expected_sms_body_message)
        subject
      end

      it "sets confirmed_sms_sent_at" do
        subject
        expect(match.reload.confirmed_sms_sent_at).to_not be(nil)
      end

      it "sets conf_sms_provider" do
        subject
        expect(match.reload.conf_sms_provider).to eq("twilio")
      end

      it "sets conf_sms_provider_id" do
        subject
        expect(match.reload.conf_sms_provider_id).to eq("smsid")
      end

      it "sets conf_sms_status" do
        subject
        expect(match.reload.conf_sms_status).to eq(Match.conf_sms_statuses[:success])
      end
    end

    context "match user has no phone_number" do
      before do
        user.update_column(:phone_number, nil)
      end

      it "does not send the confirmed sms" do
        expect(Twilio::REST::Client).not_to receive(:new)
        subject
      end
    end

    context "confirmed sms has already been sent" do
      before do
        match.update(confirmed_sms_sent_at: 10.minutes.ago)
      end

      it "does not send the sms" do
        expect(Twilio::REST::Client).not_to receive(:new)
        subject
      end
    end

    context "confirmed has conf_sms_status in error" do
      before do
        match.conf_sms_status_error!
      end

      it "does not send the sms" do
        expect(Twilio::REST::Client).not_to receive(:new)
        subject
      end
    end

    context "Twilio raises an error" do
      it "set the conf_sms_status to error" do
        allow(twilio_mock).to receive_message_chain(:messages, :create).and_raise(Twilio::REST::TwilioError)

        SendConfirmedMatchSmsJob.new.perform(match.id)
        expect(match.reload.conf_sms_status).to eq(Match.conf_sms_statuses[:error])
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
      SendConfirmedMatchSmsJob.new.perform(match.id)
    }

    context "match is confirmed" do
      it "sends the confirmed sms" do
        expect(sendinblue_mock).to receive(:send_transac_sms).with(sender: "Covidliste", recipient: user.phone_number, content: "RDV confirmé dim 23/05 12h50 - 13h15\nBicycle rights blue bottle typewriter copp..., Paris\nPlus d'info sur http://localhost:3000/m/#{match.match_confirmation_token}/c_sms")
        subject
      end

      it "sets confirmed_sms_sent_at" do
        subject
        expect(match.reload.confirmed_sms_sent_at).to_not be(nil)
      end

      it "sets conf_sms_provider" do
        subject
        expect(match.reload.conf_sms_provider).to eq("sendinblue")
      end

      it "sets conf_sms_provider_id" do
        subject
        expect(match.reload.conf_sms_provider_id).to eq("smsid")
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

    context "confirmed sms has already been sent" do
      before do
        match.update(confirmed_sms_sent_at: 10.minutes.ago)
      end

      it "does not send the sms" do
        expect(SibApiV3Sdk::TransactionalSMSApi).not_to receive(:new)
        subject
      end
    end

    context "match has conf_sms_status in error" do
      before do
        match.conf_sms_status_error!
      end

      it "does not send the sms" do
        expect(SibApiV3Sdk::TransactionalSMSApi).not_to receive(:new)
        subject
      end
    end
  end
end
