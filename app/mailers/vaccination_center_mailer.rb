class VaccinationCenterMailer < ApplicationMailer
  default from: "Covidliste <partenaires@covidliste.com>"

  def confirmed_vaccination_center_onboarding
    @vaccination_center = params[:vaccination_center]
    partner_email = @vaccination_center&.partners&.first&.email
    @tutorial_url = "https://docs.google.com/document/d/10IqYk739dJImngTIsQ7IJbf7RXJRG7drD4dZM_Z4xmI/edit?usp=sharing"

    return if partner_email.blank?

    mail(
      to: partner_email,
      subject: "Covidliste - validation de votre lieu de vaccination"
    )
  end
end
