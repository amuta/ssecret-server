module Authentication
  class Result
    include ActiveModel::API

    attr_accessor :user, :error_code

    ERRORS = {
      expired: "Request has expired",
      invalid_auth: "Authentication failed",
      missing_params: "Missing authentication parameters"
    }.freeze

    def initialize(user: nil, error_code: nil)
      @user = user
      @error_code = error_code
    end

    def success?
      user.present?
    end

    def error_message
      return nil if success?
      ERRORS[error_code] || ERRORS[:invalid_auth]
    end

    def as_json(*)
      if success?
        { success: true }
      else
        { success: false, error: error_message }
      end
    end
  end
end
