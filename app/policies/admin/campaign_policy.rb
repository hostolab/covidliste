module Admin
  class CampaignPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user&.has_role?(:admin)

        scope.all
      end
    end

    def index?
      user.has_role?(:admin)
    end

    alias_method :show?, :index?
  end
end
