class OmniauthBimedocService < BaseOmniauthService
  def initialize(omniauth_info)
    Rails.logger.debug(omniauth_info.to_json) # TODO REMOVE THIS DEBUG
    @omniauth_info = omniauth_info
    @sub = omniauth_info.sub
    @provider_id = "bimedoc"
    @service_name = "Bimedoc"
  end

  def info
    {
      provider_id: provider_id,
      service_name: service_name,
      sub: sub,
      # TODO remove omniauth_info DEBUG
      DEBUG_RAW_DATA: omniauth_info
      # first_name: omniauth_info.given_name,
      # last_name: omniauth_info.family_name,
      # identifier: omniauth_info.SubjectNameID,
    }
  end
end
