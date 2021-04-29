module Admin
  class StatsPolicy < ApplicationPolicy
    def stats?
      user.has_role?(:admin)
    end
  end
end
