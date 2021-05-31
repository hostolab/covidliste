module Admin
  module PowerUsers
    class UserPolicy < ApplicationPolicy
      class Scope < Scope
        def resolve
          raise Pundit::NotAuthorizedError unless user.has_role?(:admin)
          scope.with_roles.distinct
        end
      end

      def index?
        user.has_role?(:admin)
      end

      def create?
        user.has_role?(:super_admin)
      end

      def update?
        user.has_role?(:super_admin)
      end

      def destroy?
        user.has_role?(:super_admin)
      end
    end
  end
end
