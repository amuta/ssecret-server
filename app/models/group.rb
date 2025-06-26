class Group < ApplicationRecord
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  has_many :secret_accesses, dependent: :destroy
  has_many :secrets, through: :secret_accesses, source: :secret

  validates :name, presence: true, uniqueness: true

  scope :personal, -> { where(is_personal: true) }

  def key_for_user(user)
    group_memberships.find_by(user: user)&.encrypted_group_key
  end

  def add_member(user, role: :member, encrypted_group_key: nil)
    group_memberships.create(user: user, role: role, encrypted_group_key: encrypted_group_key)
  end

  def add_secret(secret, role: :read, encrypted_dek: nil)
    secret_accesses.create(secret: secret, role: role, encrypted_dek: encrypted_dek)
  end

  def admin?(user)
    group_memberships.exists?(user: user, role: :admin)
  end
end
