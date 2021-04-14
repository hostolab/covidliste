class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :update]

  def show
    if @match.age != @match.user.age
      flash[:error] = "Désolé, votre âge a changé depuis l'envoi de la notification. Pas d'inquiétude, vous restez dans notre liste de volontaires ! Vous serez contacté dès qu'une dose est à nouveau disponible près de chez vous."
      redirect_to root_path
    end
  end

  def update
    if @match.expired?
      flash[:error] = "Désolé, votre invitation a expiré."
    else
      @match.confirm!
    end
  rescue Match::AlreadyConfirmedError, Match::DoseOverbookingError => e
    flash[:error] = e.message
  ensure
    render action: "show"
  end

  private

  def set_match
    @match = Match.find_by(match_confirmation_token: params[:match_confirmation_token])
    return unless @match.nil?

    flash[:error] = "Désolé, ce lien d'invitation n'est pas valide."
    redirect_to root_path
  end

  def skip_pundit?
    # TODO add a real policy
    true
  end
end
