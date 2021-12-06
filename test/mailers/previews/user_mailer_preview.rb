# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def send_user_anonymization_link_after_user_requested
    user = FactoryBot.create(:user)
    UserMailer.with(user_id: user.id).send_user_anonymization_link_after_user_requested.deliver_now
  end
end
