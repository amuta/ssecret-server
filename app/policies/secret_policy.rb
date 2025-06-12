class SecretPolicy < ApplicationPolicy
  def show?
    admin? || user_access.present?
  end

  def create?
    admin?
  end

  def update?
    admin? || user_access&.write? || user_access&.admin?
  end

  def destroy?
    admin? || user_access&.admin?
  end

  # This nested class handles collection scopes.
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.joins(:secret_accesses).where(secret_accesses: { user_id: user.id })
    end
  end

  private

  def user_access
    @user_access ||= record.secret_accesses.find_by(user_id: user.id)
  end
end
