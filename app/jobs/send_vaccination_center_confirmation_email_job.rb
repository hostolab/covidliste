class SendVaccinationCenterConfirmationEmailJob < ApplicationJob
  queue_as :mailers

  def perform(vaccination_center_id)
    vaccination_center = VaccinationCenter.find(vaccination_center_id)
    return if vaccination_center.confirmation_mail_sent_at.present?

    VaccinationCenterMailer.with(vaccination_center: vaccination_center).confirmed_vaccination_center_onboarding.deliver_now
    vaccination_center.update(confirmation_mail_sent_at: Time.now.utc)
  end
end
