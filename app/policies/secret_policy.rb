class SecretPolicy < ApplicationPolicy
  def show?
    admin? || record.access_context_for(user).present?
  end

  def create?
    true
  end

  def update?
    context = record.access_context_for(user)
    admin? || %w[write admin].include?(context&.dig(:effective_role))
  end

  def destroy?
    context = record.access_context_for(user)
    admin? || context&.dig(:effective_role) == "admin"
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.admin?

      scope.joins(:users).where(users: { id: user.id }).distinct
    end
  end

  private
end
