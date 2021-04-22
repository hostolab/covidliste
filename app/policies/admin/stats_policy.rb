module Admin
  class StatsPolicy < ApplicationPolicy
    def stats?
      user.admin?
    end
  end
end
