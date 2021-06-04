module Partners
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    SERVICES = {
      "pro_sante_connect" => OmniauthProSanteConnectService,
      "bimedoc" => OmniauthBimedocService
    }

    def try_login_or_link
      service = SERVICES.fetch(action_name).new(request.env["omniauth.auth"]["extra"]["raw_info"])
      @external_account = PartnerExternalAccount.find_by(provider_id: service.provider_id, sub: service.sub)
      if current_partner.is_a?(Partner) # If already logged-in as partner
        if @external_account.present? && @external_account.partner.present? # External account exists in DB
          if @external_account.partner.id == current_partner.id # External account is liked to current logged-in partner
            @external_account.info = service.info
            if @external_account.save
              flash[:success] = "La liaison avec le compte #{service.service_name} à été mise à jour"
            else
              flash[:alert] = "Une erreur est survenue : #{@external_account.errors.full_messages.join(", ")}"
            end
          else # External account is not liked to current logged-in partner but with another partner
            flash[:alert] = "Une erreur est survenue : Ce compte #{service.service_name} est déjà lié à un autre compte professionnel Covidliste"
          end
        else # External account does not exist in DB yet
          @external_account = PartnerExternalAccount.new(
            partner: current_partner,
            provider_id: service.provider_id,
            sub: service.sub,
            info: service.info
          )
          if @external_account.save
            flash[:success] = "Le compte #{service.service_name} à bien été lié"
          else
            flash[:alert] = "Une erreur est survenue : #{@external_account.errors.full_messages.join(", ")}"
          end
        end
        redirect_to partners_path # redirect to profile-linking area
      elsif @external_account.present? && @external_account.partner.present? # not logged-in as partner
        sign_in @external_account.partner
        session[:connected_with] = @external_account.provider_id
        redirect_to root_path # External account exists in DB
      else # External account does not exist in DB yet
        flash[:notice] = "Ce compte #{service.service_name} n'est lié à aucun compte Covidliste Pro.
            Connectez-vous à votre compte Covidliste Pro ou inscrivez-vous.
            Une fois connecté, vous pourrez lier votre compte #{service.service_name} à votre compte Covidliste Pro sur la page profil."
        # TODO use somethiong better than a flash for that
        redirect_to new_partner_session_path # redirect to profile-linking area, will display login page as we are not logged-in
      end
    end

    SERVICES.keys.each { |name| alias_method name, :try_login_or_link }

    protected

    def after_omniauth_failure_path_for(scope)
      if current_partner.is_a?(Partner) # If already logged-in as partner
        partners_path # Invalid omniauth login but logged-in, displaying profile / profile-linking area with error
      else # not logged-in as partner
        new_partner_session_path # Invalid omniauth login and not logged-in, displaying connection form with error
      end
    end
  end
end
