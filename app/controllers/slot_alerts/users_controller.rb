module SlotAlerts
  class UsersController < ApplicationController
    before_action :set_alert, only: [:destroy, :edit]
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def pundit_user
      @alert.user
    end

    def edit
    end

    def destroy
      authorize @alert.user, :delete?
      @alert.user.anonymize!
      redirect_to root_path, notice: "🎉 🎉 🎉 Votre compte a été supprimé de nos serveurs. Portez-vous bien."
    end

    private

    def set_alert
      @alert = SlotAlert.find_by(token: params[:token])

      if @alert.user.blank?
        flash[:error] = "Désolé, ce lien n’est plus valide."
        return redirect_to root_path
      end
      authorize @alert
    end

    def user_not_authorized(exception)
      policy_name = exception
        .policy.class.to_s.underscore
      message = exception.message || (t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default)
      flash[:error] = message
      redirect_back(fallback_location: root_path)
    end
  end
end
