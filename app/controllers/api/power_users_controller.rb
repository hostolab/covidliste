module Api
  class PowerUsersController < BaseController
    def index
      users = policy_scope([:power_users, User]).includes([:roles_users, :roles]).uniq
      render json: {
        power_users: users.map { |user|
          {
            email: user.email,
            fullname: user.full_name,
            roles: user.roles.map(&:name)
          }
        }
      }
    end
  end
end
