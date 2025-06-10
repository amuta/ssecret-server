module Users
  class CreateService < ApplicationService
    def initialize(username:, raw_public_key:, admin: false)
      @username = username
      @raw_public_key = raw_public_key
      @admin = admin
    end

    def call
      user = User.new(
        username: @username,
        raw_public_key: @raw_public_key,
        admin: @admin
      )

      if user.save
        success(payload: user)
      else
        failure(errors: user.errors.full_messages)
      end
    end
  end
end
