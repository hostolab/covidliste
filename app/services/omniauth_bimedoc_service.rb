class OmniauthBimedocService < BaseOmniauthService
  def initialize(omniauth_info)
    @omniauth_info = omniauth_info
    @sub = omniauth_info.sub
    @provider_id = "bimedoc"
    @service_name = "Bimedoc"
  end

  def locations
    [
      {
        finess: omniauth_info.pharmacy_finess.to_s.strip,
        name: omniauth_info.pharmacy_name.to_s.strip,
        commercial_name: "",
        address: "#{omniauth_info.pharmacy_building_number} #{omniauth_info.pharmacy_street}".gsub(/\s{2,}/, " ").strip,
        address2: "",
        address3: "#{omniauth_info.pharmacy_postcode} #{omniauth_info.pharmacy_city}".gsub(/\s{2,}/, " ").strip,
        phone: omniauth_info.pharmacy_phone_number.to_s.strip
      }
    ]
  end

  def info
    {
      provider_id: provider_id,
      service_name: service_name,
      sub: sub,
      first_name: omniauth_info.first_name,
      last_name: omniauth_info.last_name,
      identifier: omniauth_info.rpps_number,
      locations: locations,
      raw: omniauth_info
    }
  end
end
