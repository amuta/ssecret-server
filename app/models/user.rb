class User < ApplicationRecord
  include JwtAuthenticatable

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "can only contain letters, numbers, underscore, and hyphen" }

  validates :ssh_public_key, presence: false

  has_many :secret_sets, foreign_key: "created_by_user_id"
  has_many :secret_set_accesses
  has_many :shared_secret_sets, through: :secret_set_accesses, source: :secret_set

  def generate_jwt
    JWT.encode({ user_id: id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
  end

  def self.from_jwt(token)
    decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" })
    user_id = decoded_token[0]["user_id"]
    find_by(id: user_id)
  rescue JWT::DecodeError
    nil
  end
end
