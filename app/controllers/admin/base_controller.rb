module Admin
  class BaseController < ApplicationController
    include AdminHelper
    include Pagy::Backend

    layout "/admin_application"

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      redirect_to(root_path, notice: "Vous n'êtes pas autorisé à faire cette action")
    end

    # Redefine pundit specific methods to handle :admin namespace properly
    def policy_scope(scope)
      super([:admin, scope])
    end

    def authorize(record, query = nil)
      super([:admin, record], query)
    end
  end
end
