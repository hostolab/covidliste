require "omniauth_openid_connect"

module OmniAuth
  module Strategies
    class ProSanteConnect < OpenIDConnect
      def request_phase
        if PartnerExternalAccountProvider::Providers::ALL.key?(:pro_sante_connect)
          super
        else
          fail!("La connexion via Pro Santé Connect est désactivée actuellement")
        end
      end
    end
  end
end

OmniAuth.config.add_camelization("pro_sante_connect", "ProSanteConnect")
