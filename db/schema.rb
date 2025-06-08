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

ActiveRecord::Schema[8.0].define(version: 2025_06_08_171707) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "encrypted_values", force: :cascade do |t|
    t.integer "secret_set_id"
    t.string "key"
    t.text "enc_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["secret_set_id"], name: "index_encrypted_values_on_secret_set_id"
  end

  create_table "secret_set_accesses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "secret_set_id"
    t.text "dek_encrypted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["secret_set_id"], name: "index_secret_set_accesses_on_secret_set_id"
    t.index ["user_id"], name: "index_secret_set_accesses_on_user_id"
  end

  create_table "secret_sets", force: :cascade do |t|
    t.string "name"
    t.integer "created_by_user_id"
    t.text "dek_encrypted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_secret_sets_on_created_by_user_id"
  end

  create_table "secrets", force: :cascade do |t|
    t.string "key"
    t.text "content"
    t.bigint "secret_set_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["secret_set_id"], name: "index_secrets_on_secret_set_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.text "ssh_public_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "secrets", "secret_sets"
end
