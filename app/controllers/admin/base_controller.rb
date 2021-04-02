# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController

    include AdminHelper
    before_action :require_role!
    layout '/admin_application'

    private

    def require_role!
      authenticate_user!
      return if current_user.has_role?(:super_admin)
      flash[:alert] = "Vous n'êtes pas autorisé à accéder à cette page !"
      redirect_to(root_path)
    end

  end
end
