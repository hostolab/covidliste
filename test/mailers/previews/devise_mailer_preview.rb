# frozen_string_literal: true

class DeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    @resource = User.last || FactoryBot.create(:user)
    @token = "faketoken"
    DeviseMailer.confirmation_instructions(@resource, @token).deliver_now
  end

  def reset_password_instructions
    @resource = Partner.last || FactoryBot.create(:partner)
    @token = "faketoken"
    DeviseMailer.reset_password_instructions(@resource, @token).deliver_now
  end

  def unlock_instructions
    @resource = Partner.last || FactoryBot.create(:partner)
    @token = "faketoken"
    DeviseMailer.unlock_instructions(@resource, @token).deliver_now
  end

  def magic_link
    @resource = User.last || FactoryBot.create(:user)
    @token = "faketoken"
    @remember_me = false
    Devise::Passwordless::Mailer.magic_link(@resource, @token, @remember_me).deliver_now
  end
end
