class SecretAccess < ApplicationRecord
  belongs_to :group
  belongs_to :secret

  enum :role, { read: 0, write: 1, admin: 2 }

  validates :encrypted_dek, presence: true
  validates :role, presence: true
  validates :group_id, uniqueness: { scope: :secret_id }
end
