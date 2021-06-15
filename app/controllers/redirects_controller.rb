# This controller holds temporary redirection logic.
# After a while, it would be fine removing each action as it shouldn't be used anymore.
class RedirectsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_root_with_message
  rescue_from ArgumentError, with: :redirect_to_root_with_message

  def confirm_destroy_from_match
    redirect_to confirm_destroy_path(
      Match.find_by!(match_confirmation_token: params[:match_confirmation_token]).user
    )
  end

  def confirm_destroy_from_slot_alert
    redirect_to confirm_destroy_path(
      SlotAlert.find_by!(token: params[:token]).user
    )
  end

  private

  def skip_pundit?
    true
  end

  def redirect_to_root_with_message
    flash[:error] = "Désolé, ce lien n’est plus valide."
    redirect_to root_path
  end

  def confirm_destroy_path(user)
    raise ArgumentError if user.anonymized_at

    token = user.signed_id(purpose: "users.destroy", expires_in: 1.minute)
    confirm_destroy_profile_path(authentication_token: token)
  end
end
