module Admin
  module PowerUsers
    class UserPolicy < ApplicationPolicy
      class Scope < Scope
        def resolve
          raise Pundit::NotAuthorizedError unless user.super_admin?

          scope.with_roles
        end
      end

      def index?
        user.super_admin?
      end
    end
  end
end
