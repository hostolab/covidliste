# frozen_string_literal: true

class Devise::Passwordless::SessionsController < Devise::SessionsController
  def create
    self.resource = resource_class.find_by(email: create_params[:email])
    if resource
      resource.send_magic_link(create_params[:remember_me])
      set_flash_message(:notice, :magic_link_sent, now: true)
    else
      set_flash_message(:alert, :not_found_in_database, now: true)
    end

    self.resource = resource_class.new(create_params)
    render :new
  end

  protected

  def translation_scope
    if action_name == "create"
      "devise.passwordless"
    else
      super
    end
  end

  private

  def create_params
    resource_params.permit(:email, :remember_me)
  end
end
