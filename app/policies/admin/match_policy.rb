module Admin
  class MatchPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user&.has_role?(:support_member)

        scope.all
      end
    end
  end
end
