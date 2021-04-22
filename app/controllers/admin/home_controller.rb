module Admin
  class HomeController < BaseController
    before_action :skip_policy_scope, only: :index
    before_action -> { authorize(:home) }

    def index
    end
  end
end
