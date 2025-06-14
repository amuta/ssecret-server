module Users
  class CreateService < ApplicationService
    def initialize(username:, raw_public_key:, personal_group_encrypted_key:)
      @username = username
      @raw_public_key = raw_public_key
      @personal_group_encrypted_key = personal_group_encrypted_key
    end

    def call
      user = User.new(username: @username, raw_public_key: @raw_public_key)
      group = Group.personal.find_or_initialize_by(name: "#{@username}-personal")
      membership = GroupMembership.new(
        user: user,
        group: group,
        role: :admin, # A user is always an admin of their own personal group.
        encrypted_group_key: @personal_group_encrypted_key
      )

      ActiveRecord::Base.transaction do
        user.save!
        group.save!
        membership.save!
      end

      success(payload: user)
    rescue ActiveRecord::RecordInvalid => e
      failure(errors: e.record.errors.full_messages)
    end
  end
end
