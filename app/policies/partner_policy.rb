class PartnerPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.none
    end
  end

  def show?
    user.confirmed? && user == record
  end

  def create?
    true
  end

  def update?
    user.confirmed? && user == record
  end

  def destroy?
    user == record
  end
end
