class User < ApplicationRecord
  include JwtAuthenticatable
  include PrivateKeyAuthenticable
  include PublicKeyNormalizable

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "can only contain letters, numbers, underscore, and hyphen" }
  validates :public_key, presence: false

  has_many :secret_accesses
  has_many :secrets, through: :secret_accesses
end
