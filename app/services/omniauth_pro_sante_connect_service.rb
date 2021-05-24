class OmniauthProSanteConnectService < BaseOmniauthService
  def initialize(omniauth_info)
    @omniauth_info = omniauth_info
    @sub = omniauth_info.sub
    @provider_id = "pro_sante_connect"
    @service_name = "Pro Santé Connect"
  end

  def info
    {
      provider_id: provider_id,
      service_name: service_name,
      sub: sub,
      first_name: omniauth_info.given_name,
      last_name: omniauth_info.family_name,
      identifier: omniauth_info.SubjectNameID
    }
  end
end
