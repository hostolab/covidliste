require "omniauth_openid_connect"

module OmniAuth
  module Strategies
    class Bimedoc < OpenIDConnect
      def request_phase
        if PartnerExternalAccountProvider::Providers::ALL.key?(:bimedoc)
          super
        else
          fail!("La connexion via Bimedoc est désactivée actuellement")
        end
      end
    end
  end
end

OmniAuth.config.add_camelization("bimedoc", "Bimedoc")
