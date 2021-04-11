# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include AdminHelper
    include Pagy::Backend
    before_action :require_role!
    layout "/admin_application"

    private

    def require_role!
      authenticate_user!
      unless current_user.admin?
        flash[:alert] = "Vous n'êtes pas autorisé à accéder à cette page !"
        redirect_to(root_path)
      end
    end

    def skip_pundit?
      # TODO add a real policy
      true
    end
  end
end
