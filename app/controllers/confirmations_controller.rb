class ConfirmationsController < ::Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?
    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)

      # PasswordLess specific behaviour after confirmation there is a direct sign in
      sign_in(resource) if resource.is_a?(User)

      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    elsif resource.confirmed?
      set_flash_message!(:notice, :already_confirmed)
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { redirect_to resource.is_a?(Partner) ? :new_partner_session : :new_user_session }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  def after_confirmation_path_for(_resource_name, resource)
    if resource.is_a?(Partner)
      # NOTE(ssaunier): We already have a valid password at sign up
      partners_vaccination_centers_path
    elsif resource.is_a?(User)
      profile_path
    else
      new_user_session_path
    end
  end
end
