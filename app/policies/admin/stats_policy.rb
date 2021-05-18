module Admin
  class StatsPolicy < ApplicationPolicy
    def stats?
      user.has_role?(:supply_admin)
    end
  end
end
