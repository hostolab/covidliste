class VaccinationCenterMailer < ApplicationMailer
  default from: "Covidliste <partenaires@covidliste.com>"

  def confirmed_vaccination_center_instructions
    @vaccination_center = params[:vaccination_center]
    partner_email = @vaccination_center&.partners&.first&.email

    return if partner_email.blank?

    mail(
      to: partner_email,
      subject: "Covidliste - validation de votre lieu de vaccination"
    )
  end
end
