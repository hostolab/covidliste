# frozen_string_literal: true

class VaccinationCenterMailerPreview < ActionMailer::Preview
  def confirmed_vaccination_center_onboarding
    partner = FactoryBot.create(:partner)
    vaccination_center = FactoryBot.create(:vaccination_center, partners: [partner])
    VaccinationCenterMailer.with(vaccination_center: vaccination_center).confirmed_vaccination_center_onboarding.deliver_now
  end
end
