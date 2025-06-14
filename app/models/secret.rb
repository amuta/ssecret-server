class Secret < ApplicationRecord
  has_many :secret_accesses, dependent: :destroy
  has_many :groups, through: :secret_accesses
  has_many :group_memberships, through: :groups
  has_many :users, through: :group_memberships
  has_many :items, dependent: :destroy

  accepts_nested_attributes_for :items, allow_destroy: true

  validates :name, presence: true

  def access_context_for(user)
    access_paths_data = user.secret_accesses
      .where(secret: self)
      .select(
        "groups.id as group_id",
        "groups.name as group_name",
        "groups.is_personal",
        "secret_accesses.role",
        "secret_accesses.encrypted_dek",
        "group_memberships.encrypted_group_key"
      )

    return nil if access_paths_data.empty?

    # Transform the raw database results into the structured access_paths array.
    roles = []
    access_paths = access_paths_data.map do |record|
      roles << SecretAccess.roles[record.role.to_sym]
      {
        via_group: { id: record.group_id, name: record.group_name, personal: record.is_personal },
        role: record.role,
        key_chain: {
          encrypted_dek: record.encrypted_dek,
          encrypted_group_key: record.encrypted_group_key
        }
      }
    end

    # Calculate the highest role level from the collected data.
    max_role_value = SecretAccess.roles.key(roles.max)

    {
      effective_role: max_role_value,
      access_paths: access_paths
    }
  end
end
