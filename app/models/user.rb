class User < ApplicationRecord
  include JwtAuthenticatable

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "can only contain letters, numbers, underscore, and hyphen" }
  validates :public_key, presence: false

  # Item Sets created by this user
  has_many :created_secret_sets,
           class_name: "SecretSet",
           foreign_key: "created_by_user_id"

  # Item Sets shared with this user
  has_many :secret_set_accesses
  has_many :secret_sets, through: :secret_set_accesses

  before_save :set_public_key_hash, if: :public_key_changed?


  def verify_signature(string_to_verify, signature)
    return false unless public_key.present?

    begin
      key = OpenSSL::PKey::RSA.new(public_key)
      decoded_signature = Base64.strict_decode64(signature)
      key.verify(OpenSSL::Digest::SHA256.new, decoded_signature, string_to_verify)
    rescue OpenSSL::PKey::RSAError
      false
    end
  end

  private

  def set_public_key_hash
    self.public_key_hash = Digest::SHA256.hexdigest(public_key)
  end
end
