class Admin::UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        raise Pundit::NotAuthorizedError
      end
    end
  end

  def resend_confirmation?
    user.admin?
  end

  def destroy?
    user.super_admin?
  end
end
