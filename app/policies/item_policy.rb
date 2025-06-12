class ItemPolicy < ApplicationPolicy
  def show?
    parent_policy.show?
  end

  def create?
    parent_policy.update?
  end

  def update?
    parent_policy.update?
  end

  def destroy?
    # Example of adding intrinsic logic:
    # return false if record.metadata["locked"] == true
    parent_policy.update?
  end

  private

  def parent_policy
    @parent_policy ||= SecretPolicy.new(user, record.secret)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # Scope items to secrets the user can access.
      scope.joins(:secret).where(secrets: { id: SecretPolicy::Scope.new(user, Secret).resolve.select(:id) })
    end
  end
end
