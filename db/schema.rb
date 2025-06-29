# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_14_145043) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.integer "action", null: false
    t.integer "status", null: false
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "correlation_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["correlation_id"], name: "index_audit_logs_on_correlation_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.integer "role", default: 0, null: false
    t.text "encrypted_group_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.boolean "is_personal", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "key"
    t.text "content"
    t.bigint "secret_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata", default: {}
    t.index ["secret_id"], name: "index_items_on_secret_id"
  end

  create_table "secret_accesses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "secret_id"
    t.text "encrypted_dek"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.bigint "group_id"
    t.index ["group_id"], name: "index_secret_accesses_on_group_id"
    t.index ["secret_id"], name: "index_secret_accesses_on_secret_id"
    t.index ["user_id"], name: "index_secret_accesses_on_user_id"
  end

  create_table "secrets", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.text "public_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.string "public_key_hash"
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["public_key_hash"], name: "index_users_on_public_key_hash", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "audit_logs", "users"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "items", "secrets"
  add_foreign_key "secret_accesses", "groups"
end
