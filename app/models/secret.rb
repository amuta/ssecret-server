class Secret < ApplicationRecord
  has_many :secret_accesses, dependent: :destroy
  has_many :users, through: :secret_accesses
  has_many :items, dependent: :destroy

  has_one :owner_access,
          -> { where(permissions: :admin) },
          class_name: "SecretAccess"
  has_one :owner, through: :owner_access, source: :user

  validates :name, presence: true

  scope :accessible_by, ->(user) {
    joins(:secret_accesses)
      .where(secret_accesses: { user_id: user.id })
  }

  def assign_owner!(user, dek_encrypted)
    secret_accesses.create!(
      user: user,
      permissions: :admin,
      dek_encrypted: dek_encrypted
    )
  end
end
