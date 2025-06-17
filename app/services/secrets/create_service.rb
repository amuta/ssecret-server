module Secrets
  class CreateService < ApplicationService
    def initialize(user:, name:, access_grants:, items_attributes: nil)
      @user = user
      @name = name
      @items_attributes = items_attributes || []
      @access_grants = access_grants || []
    end

    def call
      return failure(errors: [ "Group not found or user do not have access to it." ]) unless user_can_add_credential_to_groups?

      secret = build_secret

      if secret.save
        event = Audit::SecretCreated.new(secret: secret)
        EventPublisher.publish(event)
        success(payload: secret)
      else
        failure(errors: secret.errors.full_messages)
      end
    end

    private

    def build_secret
      Secret.new(
        name: @name,
        items_attributes: @items_attributes
      ).tap do |secret|
        @access_grants.each do |grant|
          secret.secret_accesses.build(
            group_id: grant[:group_id],
            role: grant[:role],
            encrypted_dek: grant[:encrypted_dek]
          )
        end
      end
    end

    # TODO - This should be moved to a separate service or policy class that handles authorization logic.
    def user_can_add_credential_to_groups?
      return [] unless @access_grants

      user_groups = @user.groups.includes(:group_memberships).index_by(&:id)
      @access_grants.each do |grant|
        group = user_groups[grant[:group_id].to_i]

        return false unless group && group.group_memberships.admins.exists?(user: @user)
      end

      true
    end

    def load_group
    end
  end
end
