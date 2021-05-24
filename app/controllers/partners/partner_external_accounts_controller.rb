module Partners
  class PartnerExternalAccountsController < ApplicationController
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def pundit_user
      current_partner
    end

    def destroy
      @partner_external_account = current_partner.partner_external_accounts.find(params[:id])
      authorize @partner_external_account.partner
      service_name = @partner_external_account.service_name
      if @partner_external_account.destroy
        redirect_to partners_path, notice: "Compte #{service_name} délié."
      else
        flash[:error] = "Une erreur est survenue : #{@partner_external_account.errors.full_messages.join(", ")}"
        redirect_to partners_path
      end
    end

    private

    def user_not_authorized(exception)
      policy_name = exception
        .policy.class.to_s.underscore
      message = exception.message || (t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default)
      flash[:error] = message
      redirect_back(fallback_location: root_path)
    end
  end
end
