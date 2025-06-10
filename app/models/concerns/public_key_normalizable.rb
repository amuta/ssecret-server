module PublicKeyNormalizable
  extend ActiveSupport::Concern

  included do
    attr_writer :raw_public_key
    before_validation :normalize_and_set_public_key, if: :raw_public_key_present?
  end

  private

  def normalize_and_set_public_key
    key = load_key_from_string(@raw_public_key)

    unless key
      errors.add(:raw_public_key, "is not a valid or supported public key format")
      return
    end

    unless key.is_a?(OpenSSL::PKey::RSA)
      errors.add(:raw_public_key, "must be an RSA key")
      return
    end

    self.public_key = key.to_pem
  end

  def load_key_from_string(key_string)
    sanitized_string = key_string.strip
    key = nil

    if sanitized_string.start_with?("-----BEGIN")
      key = OpenSSL::PKey.read(sanitized_string)
    elsif sanitized_string.start_with?("ssh-")
      key = Net::SSH::KeyFactory.load_data_public_key(sanitized_string)
    end

    key
  rescue OpenSSL::PKey::PKeyError, Net::SSH::Exception
    nil
  end

  def raw_public_key_present?
    @raw_public_key.present?
  end
end
