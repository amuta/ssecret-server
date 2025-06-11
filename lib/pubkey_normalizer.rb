require "openssl"
require "net/ssh"
require "base64"

module PubkeyNormalizer
  Result = Struct.new(:success?, :b64_key, :hash, :error)

  def self.normalize(key_string)
    key_object = load_key_from_string(key_string)

    return Result.new(false, nil, nil, "Unsupported or invalid key format.") unless key_object

    pem_key = if key_object.private?
                key_object.public_to_pem
    else
                key_object.to_pem
    end

    b64_key = Base64.strict_encode64(pem_key)
    hash = OpenSSL::Digest::SHA256.hexdigest(pem_key)
    Result.new(true, b64_key, hash, nil)
  rescue StandardError => e
    Result.new(false, nil, nil, "Normalization failed: #{e.message}")
  end

  def self.load_key_from_string(key_string)
    return nil if key_string.nil? || key_string.strip.empty?
    stripped_key = key_string.strip

    format = which_format(stripped_key)

    case format
    when :pem
      begin
        OpenSSL::PKey.read(stripped_key)
      rescue OpenSSL::PKey::PKeyError
        nil
      end
    when :openssh
      begin
        Net::SSH::KeyFactory.load_data_public_key(stripped_key)
      rescue NotImplementedError, Net::SSH::Exception
        nil
      end
    else
      nil
    end
  end

  def self.which_format(key_string)
    return :unknown if key_string.nil? || key_string.strip.empty?

    stripped_key = key_string.strip
    if stripped_key.start_with?("-----BEGIN")
      :pem
    elsif stripped_key.start_with?("ssh-rsa", "ssh-dss", "ecdsa-sha2-nistp256", "ssh-ed25519")
      :openssh
    else
      :unknown
    end
  end
end
