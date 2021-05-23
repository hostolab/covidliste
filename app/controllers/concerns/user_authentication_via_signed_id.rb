module UserAuthenticationViaSignedId
  extend ActiveSupport::Concern

  def authenticate_user_via_signed_id!(purpose: "#{controller_name}.#{action_name}")
    if params.key?("authentication_token")
      @current_user = User.find_signed(
        params.fetch("authentication_token"),
        purpose: purpose
      )
    end

    authenticate_user! unless user_signed_in?
  end
end
