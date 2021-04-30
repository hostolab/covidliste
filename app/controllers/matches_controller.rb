class MatchesController < ApplicationController
  class MissingConfirmation < StandardError; end

  before_action :set_match, only: [:show, :update, :destroy]
  before_action :verify_age, only: [:show, :update]
  before_action :verify_expiration, only: [:update]

  def show
    track_click
  end

  def destroy
    @match.refuse!
    redirect_back(fallback_location: root_path)
  end

  def update
    check_age_and_name_confirmed!

    # This is specific to ensure the validation of the user
    # won't prevent the match confirmation is other attributes
    # than the ones edited here are invalid.
    user = @match.user
    user.reload # ensure it's fresh and unmodified
    user.assign_attributes(user_params)
    user.statement_accepted_at = Time.now.utc if user_params["statement"]
    user.toc_accepted_at = Time.now.utc if user_params["toc"]

    if user.valid_attributes?(:statement, :toc)
      user.save(validate: false)
      @match.confirm!
    else
      raise ActiveRecord::RecordInvalid.new(user)
    end
  rescue Match::AlreadyConfirmedError, Match::DoseOverbookingError, Match::MissingNamesError, ActiveRecord::RecordInvalid, MissingConfirmation => e
    flash.now[:error] = e.message

    # Updating the match's confirmation_failed_at to indicate it failed.
    # This should help with detecting critical bugs.
    @match.update_columns(confirmation_failed_at: Time.now.utc, confirmation_failed_reason: e.class.to_s)

    # Reloading @match so it's back to the previous state, in particular
    # confirmed_at is nil again.
    @match.reload
  ensure
    render action: "show", status: flash[:error].present? ? :unprocessable_entity : :ok
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :statement, :toc)
  end

  def verify_age
    unless @match.age == @match.user.age
      flash[:error] = "Désolé, votre âge a changé depuis l’envoi de la notification. Pas d’inquiétude, vous restez dans notre liste de volontaires ! Vous serez contacté dès qu’une dose est à nouveau disponible près de chez vous."
      redirect_to root_path
    end
  end

  def verify_expiration
    if @match.expired?
      flash.now[:error] = "Désolé, votre invitation a expiré."
      render action: "show", status: :unprocessable_entity
    end
  end

  def set_match
    @match = Match.find_by(match_confirmation_token: params[:match_confirmation_token])

    if @match.blank?
      flash[:error] = "Désolé, ce lien d’invitation n’est pas valide."
      redirect_to root_path
    elsif @match.user.blank?
      flash[:error] = "Désolé, ce lien d’invitation n’est plus valide. L’utilisateur a été supprimé."
      redirect_to root_path
    end
  end

  def track_click
    source = params[:source]
    if source == "email"
      @match.email_first_clicked_at ||= Time.now.utc
    elsif source == "sms"
      @match.sms_first_clicked_at ||= Time.now.utc
    end
    @match.save
  end

  def skip_pundit?
    # TODO add a real policy
    true
  end

  def check_age_and_name_confirmed!
    unless ActiveRecord::Type::Boolean.new.cast(params["confirm_age"]) &&
        ActiveRecord::Type::Boolean.new.cast(params["confirm_name"])
      raise MissingConfirmation, "Vous devez confirmer votre âge et votre nom"
    end
  end
end
