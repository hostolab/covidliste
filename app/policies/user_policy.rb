class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.none
    end
  end

  def show?
    user.confirmed? && user == record
  end

  def create?
    true
  end

  def update?
    return false unless user.confirmed?

    if user.matches.confirmed.any?
      raise Pundit::NotAuthorizedError, "Vous ne pouvez pas modifier vos informations actuellement car vous avez confirmé un rendez-vous de vaccination. Votre profil sera anonymisé quelques jours après le RDV."
    elsif user.matches.pending.any?
      raise Pundit::NotAuthorizedError, "Vous ne pouvez pas modifier vos informations actuellement car vous avez une proposition rendez vous de vaccination en cours."
    end

    user == record
  end

  def destroy?
    if user.matches.confirmed.any?
      raise Pundit::NotAuthorizedError, "Vous ne pouvez pas supprimer vos informations actuellement car vous avez confirmé un rendez-vous de vaccination. Votre profil sera anonymisé quelques jours après le RDV."
    end

    user == record
  end
end
