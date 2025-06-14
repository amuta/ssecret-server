module Secrets
  class CreateService < ApplicationService
    def initialize(user:, name:, dek:, group_id: nil, items_attributes: nil)
      @user = user
      @group_id = group_id
      @name = name
      @dek = dek
      @items_attributes = items_attributes || []
    end

    def call
      return failure(errors: [ "Group not found or user do not have access to it." ]) if !load_group
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
        secret.secret_accesses.build(
          group: @group,
          role: :admin, # TODO - work this out / have a way to specify this
          encrypted_dek: @dek
        )
      end
    end

    def load_group
      if @group_id.nil?
        @group = @user.personal_group
      else
        @group = @user.groups.find_by(id: @group_id)

        if @group.nil?
          return false
        end
      end

      true
    end
  end
end
