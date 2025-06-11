class SignatureAuthenticator
  def initialize(request)
    @request = request
    @signature = request.headers["X-Signature"]
    @timestamp = request.headers["X-Timestamp"]
    @key_hash = request.headers["X-Key-Hash"]
  end

  def authenticate
    return Authentication::Result.new(error_code: :missing_params) unless valid_headers?
    return Authentication::Result.new(error_code: :expired) unless timestamp_valid?

    user = find_and_verify_user
    if user
      Authentication::Result.new(user: user)
    else
      Authentication::Result.new(error_code: :invalid_auth)
    end
  end

  private

  def valid_headers?
    @signature.present? && @timestamp.present? && @key_hash.present?
  end

  def timestamp_valid?
    timestamp_age = Time.now.to_i - @timestamp.to_i
    timestamp_age < 5.minutes.to_i
  end

  def find_and_verify_user
    user = User.find_by(public_key_hash: @key_hash)
    return nil unless user

    is_valid = SignatureVerifier.call(
      user: user,
      string_to_verify: string_to_verify,
      signature: @signature
    )

    is_valid ? user : nil
  end

  def string_to_verify
    "#{@request.method}#{@request.fullpath}#{@request.raw_post}#{@timestamp}"
  end
end
