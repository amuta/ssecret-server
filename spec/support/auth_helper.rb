module AuthHelper
  def sign_request(user:, endpoint:, method: "GET", body: "", timestamp: Time.now.to_i)
    # For tests, we generate an ephemeral key pair
    private_key = OpenSSL::PKey::RSA.new(2048)

    # Update user with only the public key info if not present
    unless user.public_key.present?
      user.update!(
        public_key: private_key.public_key.to_pem,
        public_key_hash: Digest::SHA256.hexdigest(private_key.public_key.to_pem)
      )
    end

    # Create string to sign
    string_to_sign = "#{method}#{endpoint}#{body}#{timestamp}"

    # Generate signature using ephemeral private key
    signature = private_key.sign(OpenSSL::Digest::SHA256.new, string_to_sign)

    # Return headers for authentication
    {
      'X-Signature': Base64.strict_encode64(signature),
      'X-Timestamp': timestamp.to_s,
      'X-Key-Hash': user.public_key_hash
    }
  end
end
