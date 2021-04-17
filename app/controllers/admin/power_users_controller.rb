module Admin
  class PowerUsersController < BaseController
    before_action :set_user, only: %i[resend_confirmation destroy]

    def index
      @users = policy_scope([:admin, :power_users, User.all]).distinct
    end
  end
end
