module Admin
  class VaccinationCenterPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user&.has_role?(:admin)

        scope.all
      end
    end

    def index?
      user.has_role?(:admin)
    end

    alias_method :new?, :index?
    alias_method :show?, :index?
    alias_method :create?, :index?
    alias_method :validate?, :index?
    alias_method :enable?, :index?
    alias_method :disable?, :index?
    alias_method :edit?, :index?
    alias_method :update?, :index?
    alias_method :destroy?, :index?
    alias_method :add_partner?, :index?
  end
end
