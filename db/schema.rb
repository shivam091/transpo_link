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

ActiveRecord::Schema[8.0].define(version: 2025_02_01_095137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "color_schemes", ["auto", "dark", "light"]

  create_table "request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uuid"
    t.string "uri"
    t.string "method"
    t.string "session_id"
    t.string "session_private_id"
    t.inet "remote_address"
    t.decimal "elapsed_time", precision: 10, scale: 4, default: "0.0"
    t.string "user_agent"
    t.string "referrer"
    t.text "exception_message"
    t.integer "status"
    t.integer "response_size"
    t.jsonb "query_params", default: "{}"
    t.jsonb "ip_info", default: "{}"
    t.uuid "user_id"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["ip_info"], name: "index_request_logs_on_ip_info", using: :gin
    t.index ["query_params"], name: "index_request_logs_on_query_params", using: :gin
    t.index ["remote_address"], name: "index_request_logs_on_remote_address"
    t.index ["session_id"], name: "index_request_logs_on_session_id"
    t.index ["user_id"], name: "index_request_logs_on_user_id"
    t.index ["uuid"], name: "index_request_logs_on_uuid", unique: true
    t.check_constraint "ip_info IS NOT NULL", name: "check_request_logs_ip_info_presence"
    t.check_constraint "method IS NOT NULL AND method::text <> ''::text", name: "check_request_logs_method_presence"
    t.check_constraint "remote_address IS NOT NULL", name: "check_request_logs_remote_address_presence"
    t.check_constraint "upper(method::text) = method::text", name: "check_request_logs_method_uppercase"
    t.check_constraint "uri IS NOT NULL AND uri::text <> ''::text", name: "check_request_logs_uri_presence"
    t.check_constraint "uuid IS NOT NULL AND uuid::text <> ''::text", name: "check_request_logs_uuid_presence"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.check_constraint "char_length(name::text) <= 55 AND char_length(name::text) >= 2", name: "check_roles_name_length"
    t.check_constraint "name IS NOT NULL AND name::text <> ''::text", name: "check_roles_name_presence"
  end

  create_table "user_details", primary_key: "user_id", id: :uuid, default: nil, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "mobile_number"
    t.string "alternate_contact_number"
    t.string "alternate_email"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["mobile_number"], name: "index_user_details_on_mobile_number", unique: true
    t.index ["user_id"], name: "index_user_details_on_user_id", unique: true
    t.check_constraint "char_length(alternate_contact_number::text) <= 55 AND char_length(alternate_contact_number::text) >= 2", name: "check_user_details_alternate_contact_number_length"
    t.check_constraint "char_length(alternate_email::text) <= 55 AND char_length(alternate_email::text) >= 2", name: "check_user_details_alternate_email_length"
    t.check_constraint "char_length(first_name::text) <= 55 AND char_length(first_name::text) >= 2", name: "check_user_details_first_name_length"
    t.check_constraint "char_length(last_name::text) <= 55 AND char_length(last_name::text) >= 2", name: "check_user_details_last_name_length"
    t.check_constraint "char_length(mobile_number::text) <= 55 AND char_length(mobile_number::text) >= 2", name: "check_user_details_mobile_number_length"
    t.check_constraint "first_name IS NOT NULL AND first_name::text <> ''::text", name: "check_user_details_first_name_presence"
    t.check_constraint "last_name IS NOT NULL AND last_name::text <> ''::text", name: "check_user_details_last_name_presence"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.timestamptz "reset_password_sent_at"
    t.timestamptz "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.timestamptz "current_sign_in_at"
    t.timestamptz "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.timestamptz "confirmed_at"
    t.timestamptz "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.timestamptz "locked_at"
    t.boolean "is_active", default: false
    t.boolean "is_banned", default: false
    t.uuid "role_id"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_active"], name: "index_users_on_is_active"
    t.index ["is_banned"], name: "index_users_on_is_banned"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.check_constraint "char_length(email::text) <= 55 AND char_length(email::text) >= 2", name: "check_users_email_length"
    t.check_constraint "email IS NOT NULL AND email::text <> ''::text", name: "check_users_email_presence"
    t.check_constraint "encrypted_password IS NOT NULL AND encrypted_password::text <> ''::text", name: "check_users_encrypted_password_presence"
  end

  add_foreign_key "request_logs", "users", name: "fk_request_logs_user_id_on_users", on_delete: :nullify
  add_foreign_key "user_details", "users", name: "fk_user_details_user_id_on_users", on_delete: :cascade
  add_foreign_key "users", "roles", name: "fk_users_role_id_on_roles", on_delete: :restrict
end
