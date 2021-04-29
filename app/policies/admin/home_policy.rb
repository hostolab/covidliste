module Admin
  class HomePolicy < ApplicationPolicy
    def index?
      user&.has_role?(:admin)
    end
  end
end
