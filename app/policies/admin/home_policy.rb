module Admin
  class HomePolicy < ApplicationPolicy
    def index?
      user&.admin?
    end
  end
end
