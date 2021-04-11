class Admin::UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def destroy?
    user.super_admin?
  end
end
