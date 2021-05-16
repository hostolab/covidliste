module Admin
  class CampaignPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user&.has_role?(:supply_admin)

        scope.all
      end
    end

    def index?
      user.has_role?(:supply_admin)
    end
  end
end
