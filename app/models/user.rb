class User < ApplicationRecord
  include JwtAuthenticatable
  include PrivateKeyAuthenticable

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "can only contain letters, numbers, underscore, and hyphen" }

  has_many :secret_accesses
  has_many :secrets, through: :secret_accesses

  validates :raw_public_key, public_key: true, allow_blank: true

  attr_accessor :raw_public_key
end
