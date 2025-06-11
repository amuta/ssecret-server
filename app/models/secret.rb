class Secret < ApplicationRecord
  has_many :secret_accesses, dependent: :destroy
  has_many :users, through: :secret_accesses
  has_many :items, dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true

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

  scope :changeable_by, ->(user) {
    joins(:secret_accesses)
      .where(secret_accesses: { user_id: user.id, permissions: [ :write, :admin ] })
  }

  validates :name, presence: true
end
