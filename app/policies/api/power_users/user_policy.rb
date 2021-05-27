module Api
  module PowerUsers
    class UserPolicy < ApplicationPolicy
      class Scope < Scope
        def resolve
          scope.with_roles.distinct
        end
      end
    end
  end
end
