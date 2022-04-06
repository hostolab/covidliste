require "rails_helper"

RSpec.describe PrivacyMailer, type: :mailer do
  describe "#send_user_anonymization_link_after_user_requested" do
    let(:mail) { described_class.with(user_id: user.id).send_user_anonymization_link_after_user_requested }
    let(:user) { create(:user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Nous avons bien reçu votre email")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["privacy@covidliste.com"])
    end

    it "includes a signed link to the confirm_destroy_profile URL" do
      match_data = mail.body.encoded.match(%r{/users/profile/confirm_destroy\?authentication_token=([^"]+)"})
      token = CGI.unescape(match_data.captures.first)
      expect(User.find_signed(token, purpose: "users.destroy")).to eq(user)
    end
  end
end
