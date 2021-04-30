class MatchPolicy < ApplicationPolicy
  def edit?
    record&.user
  end

  def destroy?
    record&.user
  end
end
