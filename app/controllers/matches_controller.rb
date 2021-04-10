class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :update]

  def show
  end

  def update
    if @match.expired?
      flash[:error] = "Désolé, votre invitation a expiré."
    else
      @match.confirm!
    end
    render action: "show"
  rescue Match::DoseOverbookingError => e
    flash[:error] = e.message
    render action: "show"
  end

  private

  def set_match
    @match = Match.find_by(match_confirmation_token: params[:match_confirmation_token])
    return unless @match.nil?

    flash[:error] = "Désolé, ce lien d'invitation n'est pas valide."
    redirect_to root_path
  end
end
