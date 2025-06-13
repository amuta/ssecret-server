class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  enum :action, {
    # Authorization Events (High-Signal: only log failures)
    authorization_failed: 0,

    # Session Events
    user_login_success: 10,
    user_login_failed: 11,

    # Secret Events
    secret_created: 20,
    secret_destroyed: 21,
    access_granted: 22,
    access_revoked: 23,

    # Item Events
    item_created: 24,
    item_updated: 25,
    item_destroyed: 26
  }

  enum :status, {
    success: 0,
    failure: 1
  }
end
