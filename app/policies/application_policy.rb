class ApplicationPolicy
  attr_reader :user, :record, :parent

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Default all permissions to false.
  # Policies should explicitly grant access by overriding these methods.
  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  private

  # A superuser admin can perform any action.
  # This check is executed first in specific policy methods.
  def admin?
    user&.admin?
  end
end
