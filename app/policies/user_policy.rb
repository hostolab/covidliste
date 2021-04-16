class UserPolicy < ApplicationPolicy

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
    if user.matches.confirmed.any?
      raise Pundit::NotAuthorizedError, "Vous ne ne pouvez plus modifier vos informations car vous avez déjà confirmé un rendez-vous."
    else
      user.confirmed? && user == record
    end
  end

  def delete?
    user == record
  end
end
