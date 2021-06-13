require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#send_inactive_user_unsubscription_request" do
    let(:mail) { described_class.with(user_id: user.id).send_inactive_user_unsubscription_request }
    let(:user) { create(:user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Attendez-vous toujours une dose de vaccin ?")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["inscription@covidliste.com"])
    end

    it "updates the last_inactive_user_email_sent_at" do
      expect { mail.deliver_now }
        .to change { user.reload.last_inactive_user_email_sent_at }
        .from(nil)
        .to(be_within(1.minute).of(Time.zone.now))
    end

    it "includes a signed link to the confirm_destroy_profile URL" do
      match_data = mail.body.encoded.match(%r{/users/profile/confirm_destroy\?authentication_token=([^"]+)"})
      token = CGI.unescape(match_data.captures.first)
      expect(User.find_signed(token, purpose: "users.destroy")).to eq(user)
    end
  end
end
