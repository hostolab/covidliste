module Admin
  module PowerUsers
    class UserPolicy < ApplicationPolicy
      class Scope < Scope
        def resolve
          raise Pundit::NotAuthorizedError unless user.has_role?(:admin)
          scope.with_roles.distinct
        end

        def index?
          raise Pundit::NotAuthorizedError unless user.has_role?(:admin)
        end
      end
    end
  end
end
