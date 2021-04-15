class Admin::PowerUsers::UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.with_roles
      else
        raise Pundit::NotAuthorizedError
      end
    end
  end

  def index?
    user.super_admin?
  end
end
