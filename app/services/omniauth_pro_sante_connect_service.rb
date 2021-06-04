class OmniauthProSanteConnectService < BaseOmniauthService
  def initialize(omniauth_info)
    @omniauth_info = omniauth_info
    @sub = omniauth_info.sub
    @provider_id = "pro_sante_connect"
    @service_name = "Pro Santé Connect"
  end

  def locations
    omniauth_info&.SubjectRefPro&.exercices&.flat_map do |exercice|
      exercice&.activities&.map do |activity|
        {
          finess: activity.numeroFinessSite.to_s.strip,
          name: activity.raisonSocialeSite.to_s.strip,
          commercial_name: activity.enseigneCommercialeSite.to_s.strip,
          address: "#{activity.numeroVoie} #{activity.indiceRepetitionVoie} #{activity.codeTypeDeVoie} #{activity.libelleVoie}".gsub(/\s{2,}/, " ").strip,
          address2: activity.mentionDistribution.to_s.gsub(/\s{2,}/, " ").strip,
          address3: activity.bureauCedex.to_s.gsub(/\s{2,}/, " ").strip,
          phone: activity.telephone.to_s.strip
        }
      end
    end
  end

  def info
    {
      provider_id: provider_id,
      service_name: service_name,
      sub: sub,
      first_name: omniauth_info.given_name,
      last_name: omniauth_info.family_name,
      identifier: omniauth_info.SubjectNameID,
      locations: locations,
      raw: omniauth_info
    }
  end
end
