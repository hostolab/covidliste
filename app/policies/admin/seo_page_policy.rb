module Admin
  class SeoPagePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def index?
      user.admin?
    end

    alias_method :new?, :index?
    alias_method :create?, :index?
    alias_method :edit?, :index?
    alias_method :update?, :index?
    alias_method :destroy?, :index?
  end
end
