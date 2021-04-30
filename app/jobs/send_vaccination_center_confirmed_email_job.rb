class SendVaccinationCenterConfirmedEmailJob < ApplicationJob
  queue_as :default

  def perform(vaccination_center_id)
    vaccination_center = VaccinationCenter.find(vaccination_center_id)
    return if vaccination_center.mail_sent_at.present?

    VaccinationCenterMailer.with(vaccination_center: @vaccination_center).confirmed_vaccination_center_instructions.deliver_now

    vaccination_center.update(mail_sent_at: Time.now.utc)
  end
end
