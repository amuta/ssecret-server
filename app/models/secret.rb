class Secret < ApplicationRecord
  has_many :secret_accesses, dependent: :destroy
  has_many :users, through: :secret_accesses
  has_many :items, dependent: :destroy

  has_one :admin_access,
          -> { where(permissions: :admin) },
          class_name: "SecretAccess"
  has_one :admin, through: :admin_access, source: :user

  scope :accessible_by, ->(user) {
    joins(:secret_accesses)
      .where(secret_accesses: { user_id: user.id })
  }

  scope :managed_by, ->(user) {
    joins(:secret_accesses)
      .where(secret_accesses: { user_id: user.id, permissions: :admin })
  }


  validates :name, presence: true

  before_validation :build_admin_access, if: -> { creator_user && creator_dek }, on: :create

  # Custom attributes for creating a secret
  # These are not persisted in the database
  # but used to set the admin access during creation
  attr_accessor :creator_user, :creator_dek

  private

  def build_admin_access
    return if secret_accesses.any? { |access| access.user_id == creator_user.id }

    secret_accesses.build(
      user: creator_user,
      permissions:  :admin,
      dek_encrypted: creator_dek
    )
  end
end
