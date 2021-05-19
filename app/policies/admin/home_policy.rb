module Admin
  class HomePolicy < ApplicationPolicy
    def index?
      user&.has_role?(:volunteer)
    end
  end
end
