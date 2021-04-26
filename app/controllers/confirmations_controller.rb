class ConfirmationsController < ::Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?
    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      sign_in(resource)
      respond_with_navigational(resource) do
        redirect_to after_confirmation_path_for(resource_name, resource)
      end
    elsif resource.confirmed?
      set_flash_message!(:notice, :already_confirmed)
      respond_with_navigational(resource.errors, status: :unprocessable_entity) do
        redirect_to resource.is_a?(Partner) ? :new_partner_session : :new_user_session, status: :unprocessable_entity
      end
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) do
        render :new, status: :unprocessable_entity
      end
    end
  end

  def after_confirmation_path_for(_resource_name, resource)
    if resource.is_a?(Partner)
      partners_vaccination_centers_path
    elsif resource.is_a?(User)
      profile_path
    else
      new_user_session_path
    end
  end
end
