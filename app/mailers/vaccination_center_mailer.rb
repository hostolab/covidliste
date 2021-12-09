class VaccinationCenterMailer < ApplicationMailer
  default :from => "Covidliste <partenaires@covidliste.com>", "X-Auto-Response-Suppress" => "OOF"

  def confirmed_vaccination_center_onboarding
    @tutorial_url = "https://docs.google.com/document/d/10IqYk739dJImngTIsQ7IJbf7RXJRG7drD4dZM_Z4xmI/edit?usp=sharing"
    @vaccination_center = params[:vaccination_center]
    partners = @vaccination_center&.partners

    partners.each do |partner|
      next if partner.email.blank?

      mail(
        to: partner.email,
        subject: "Covidliste - validation de votre lieu de vaccination"
      )
    end
  end
end
