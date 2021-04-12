class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.none
    end
  end

  def show?
    user == record
  end

  def create?
    true
  end

  def update?
    user == record
  end

  def delete?
    user == record
  end
end
