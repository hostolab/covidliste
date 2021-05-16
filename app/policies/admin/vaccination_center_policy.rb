module Admin
  class VaccinationCenterPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user&.has_role?(:supply_member)

        scope.all
      end
    end

    def index?
      user.has_role?(:supply_member)
    end
    alias_method :show?, :index?
    alias_method :new?, :index?
    alias_method :create?, :index?
    alias_method :edit?, :index?
    alias_method :update?, :index?
    alias_method :destroy?, :index?

    def add_partner?
      user.has_role?(:supply_admin)
    end
    alias_method :validate?, :add_partner?
    alias_method :enable?, :add_partner?
    alias_method :disable?, :add_partner?
  end
end
