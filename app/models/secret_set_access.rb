class SecretSetAccess < ApplicationRecord
  belongs_to :user
  belongs_to :secret_set

  validates :user_id, presence: true
  validates :secret_set_id, presence: true
  validates :dek_encrypted, presence: true

  # Ensures a user can't be granted access to the same secret set multiple times
  validates :user_id, uniqueness: { scope: :secret_set_id }
end
