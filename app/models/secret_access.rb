class SecretAccess < ApplicationRecord
  belongs_to :user
  belongs_to :secret

  enum :permissions, { read: 0, write: 1, admin: 2 }

  validates :dek_encrypted, presence: true
  validates :user_id, uniqueness: { scope: :secret_id }
end
