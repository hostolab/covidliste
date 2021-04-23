# frozen_string_literal: true

class Devise::Passwordless::SessionsController < Devise::SessionsController
  def create
    self.resource = resource_class.find_by(email: create_params[:email])

    resource&.send_magic_link(create_params[:remember_me])

    # always send a success message to prevent leaking information
    # about the presence or not of a user in our database
    set_flash_message(:notice, :magic_link_sent, now: true, email: create_params[:email])

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
