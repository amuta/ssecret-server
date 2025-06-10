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

ActiveRecord::Schema[8.0].define(version: 2025_06_10_163336) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "items", force: :cascade do |t|
    t.string "key"
    t.text "content"
    t.bigint "secret_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata", default: {}
    t.index ["secret_id"], name: "index_items_on_secret_id"
  end

  create_table "secret_set_accesses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "secret_id"
    t.text "dek_encrypted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "permissions", default: 0
    t.index ["secret_id"], name: "index_secret_set_accesses_on_secret_id"
    t.index ["user_id"], name: "index_secret_set_accesses_on_user_id"
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

  add_foreign_key "items", "secrets"
end
