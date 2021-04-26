require "omniauth/strategies/pro_sante_connect"
require "omniauth/strategies/bimedoc"

psc_auth_host = Rails.env.production? && !ENV["PRO_SANTE_CONNECT_FORCE_SANDBOX"] ? "auth.esw.esante.gouv.fr" : "auth.bas.esw.esante.gouv.fr"
psc_wallet_host = Rails.env.production? && !ENV["PRO_SANTE_CONNECT_FORCE_SANDBOX"] ? "wallet.esw.esante.gouv.fr" : "wallet.bas.esw.esante.gouv.fr"

bimedoc_auth_host = Rails.env.production? && !ENV["BIMEDOC_FORCE_SANDBOX"] ? "app.bimedoc.com" : "covidliste-bimedoc.web.app"
bimedoc_server_host = Rails.env.production? && !ENV["BIMEDOC_FORCE_SANDBOX"] ? "server.bimedoc.com" : "server-dev.bimedoc.com"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(:bimedoc,
    name: :bimedoc,
    scope: [:openid],
    response_type: :code,
    issuer: "https://" + bimedoc_server_host + "/o",
    client_options: {
      identifier: ENV["BIMEDOC_CLIENT_ID"],
      secret: ENV["BIMEDOC_CLIENT_SECRET"],
      redirect_uri: "#{ENV["PLATFORM_URL"] || "www.covidliste.com"}/partners/auth/bimedoc/callback",

      scheme: "https",
      port: 443,
      host: bimedoc_auth_host,

      authorization_endpoint: "https://" + bimedoc_auth_host + "/auth-request",
      token_endpoint: "https://" + bimedoc_server_host + "/o/token/",
      userinfo_endpoint: "https://" + bimedoc_server_host + "/o/token/",
      jwks_uri: "https://" + bimedoc_server_host + "/o/.well-known/jwks.json",
      post_logout_redirect_uri: "/"
    })

  provider(:pro_sante_connect,
    name: :pro_sante_connect,
    scope: [:openid, :scope_all],
    response_type: :code,
    acr_values: "eidas2",
    issuer: "https://" + psc_auth_host + "/auth/realms/esante-wallet",
    client_options: {
      identifier: ENV["PRO_SANTE_CONNECT_CLIENT_ID"],
      secret: ENV["PRO_SANTE_CONNECT_CLIENT_SECRET"],
      redirect_uri: "#{ENV["PLATFORM_URL"] || "www.covidliste.com"}/partners/auth/pro_sante_connect/callback",

      scheme: "https",
      port: 443,
      host: psc_auth_host,

      authorization_endpoint: "https://" + psc_wallet_host + "/auth",
      token_endpoint: "https://" + psc_auth_host + "/auth/realms/esante-wallet/protocol/openid-connect/token",
      userinfo_endpoint: "https://" + psc_auth_host + "/auth/realms/esante-wallet/protocol/openid-connect/userinfo",
      jwks_uri: "https://" + psc_auth_host + "/auth/realms/esante-wallet/protocol/openid-connect/certs",
      end_session_endpoint: "https://" + psc_auth_host + "/auth/realms/esante-wallet/protocol/openid-connect/logout",
      post_logout_redirect_uri: "/"
    })

  on_failure do |env|
    env["devise.mapping"] = Devise.mappings[:partner]
    Partners::OmniauthCallbacksController.action(:failure).call(env)
  end
end
