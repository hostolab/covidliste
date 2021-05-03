require "rails_helper"

describe SendVaccinationCenterConfirmationEmailJob do
  let!(:partner) { create(:partner) }
  let!(:vaccination_center) { create(:vaccination_center, lat: 42, lon: 2, partner: partner) }

  subject { SendVaccinationCenterConfirmationEmailJob.new.perform(vaccination_center.id) }

  context "vaccination center is confirmed by a volunteer" do
    it "sends the email" do
      mail = double(:mail)
      allow(VaccinationCenterMailer).to receive_message_chain("with.confirmed_vaccination_center_onboarding").and_return(mail)
      expect(mail).to receive(:deliver_now)
      subject
    end

    it "set confirmation_mail_sent_at" do
      subject
      expect(vaccination_center.reload.confirmation_mail_sent_at).to_not be(nil)
    end
  end
end
