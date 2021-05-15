module Matches
  class UsersController < ApplicationController
    before_action :set_match, only: [:edit, :destroy]

    def edit
    end

    def destroy
      @match.user.anonymize!
      redirect_to root_path, notice: "🎉 🎉 🎉 Votre compte a été supprimé de nos serveurs. Portez-vous bien."
    end

    private

    def set_match
      @match = Match.find_by(match_confirmation_token: params[:match_confirmation_token])

      if @match.blank?
        flash[:error] = "Désolé, ce lien d’invitation n’est pas valide."
        redirect_to root_path
      elsif @match.user.blank?
        flash[:error] = "Désolé, ce lien d’invitation n’est plus valide. L’utilisateur a été supprimé."
        redirect_to root_path
      end
      authorize @match
    end
  end
end
