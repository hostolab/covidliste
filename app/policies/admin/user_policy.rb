module Admin
  class Admin::UserPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user.has_role?(:admin)

        scope.all
      end
    end

    def resend_confirmation?
      user.has_role?(:admin)
    end

    def destroy?
      user.has_role?(:super_admin)
    end
  end
end
