class SecretCreator < ApplicationService
  def initialize(user:, name:, dek:, items_attributes: nil)
    @user = user
    @name = name
    @dek = dek
    @items_attributes = items_attributes || []
  end

  def call
    secret = Secret.new(name: @name, items_attributes: @items_attributes)
    secret.secret_accesses.build(
      user: @user,
      permissions: :admin,
      dek_encrypted: @dek
    )

    if secret.save
      event = Audit::SecretCreated.new(secret: secret)
      EventPublisher.publish(event)
      success(payload: secret)
    else
      failure(errors: secret.errors.full_messages)
    end
  end
end
