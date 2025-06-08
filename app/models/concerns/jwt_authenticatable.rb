module JwtAuthenticatable
  extend ActiveSupport::Concern

  def generate_jwt
    JWT.encode({ user_id: id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
  end

  class_methods do
    def from_jwt(token)
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" })
      user_id = decoded_token[0]["user_id"]
      find_by(id: user_id)
    rescue JWT::DecodeError
      nil
    end
  end
end
