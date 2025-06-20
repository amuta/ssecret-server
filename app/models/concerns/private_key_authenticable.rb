module PrivateKeyAuthenticable
  extend ActiveSupport::Concern

  def verify_signature(string_to_verify, signature)
    return false if public_key.blank?

    begin
      decoded_pem = Base64.strict_decode64(public_key)
      key_object = OpenSSL::PKey.read(decoded_pem)
      decoded_signature = Base64.strict_decode64(signature)

      key_object.verify(OpenSSL::Digest::SHA256.new, decoded_signature, string_to_verify)
    rescue OpenSSL::PKey::PKeyError, ArgumentError
      # ArgumentError is rescued for invalid Base64 strings
      false
    end
  end
end
