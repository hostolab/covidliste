module Admin
  class Admin::UserPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user.admin?

        scope.all
      end
    end

    def resend_confirmation?
      user.admin?
    end

    def destroy?
      user.super_admin?
    end
  end
end
