module Matches
  class UsersController < ApplicationController
    before_action :set_match, only: [:edit]
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def pundit_user
      @match.user
    end

    def edit
    end

    private

    def set_match
      @match = Match.find_by(match_confirmation_token: params[:match_confirmation_token])

      if @match.blank?
        flash[:error] = "Désolé, ce lien d’invitation n’est pas valide."
        return redirect_to root_path
      elsif @match.user.blank?
        flash[:error] = "Désolé, ce lien d’invitation n’est plus valide. L’utilisateur a été supprimé."
        return redirect_to root_path
      end
      authorize @match
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
