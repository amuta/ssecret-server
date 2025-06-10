module PrivateKeyAuthenticable
  extend ActiveSupport::Concern

  included do
    before_save :set_public_key_hash, if: :public_key_changed?
  end

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
