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

ActiveRecord::Schema[8.0].define(version: 2025_02_24_144350) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "color_schemes", ["auto", "dark", "light"]
  create_enum "tax_types", ["vat", "gst", "ein", "ssn", "itin", "tin", "cif", "nif", "rfc", "abn", "bn", "pan", "gstin", "cnpj", "cpf", "siret", "siren", "tan", "trn", "brn", "ird", "ubi", "cuit", "cuil", "ruc", "nit", "npwp", "kra_pin", "gst_certificate", "vatin", "qst", "pcn", "business_id", "tax_number"]

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "addressable_type"
    t.uuid "addressable_id"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.check_constraint "address1 IS NOT NULL AND address1::text <> ''::text", name: "check_addresses_address1_presence"
    t.check_constraint "char_length(address1::text) <= 100", name: "check_addresses_address1_length"
    t.check_constraint "char_length(address2::text) <= 100", name: "check_addresses_address2_length"
    t.check_constraint "char_length(postal_code::text) <= 20", name: "check_addresses_postal_code_length"
    t.check_constraint "country IS NOT NULL AND country::text <> ''::text", name: "check_addresses_country_presence"
  end

  create_table "request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uuid"
    t.string "uri"
    t.string "method"
    t.jsonb "query_params", default: "{}"
    t.string "session_id"
    t.string "session_private_id"
    t.inet "remote_address"
    t.string "user_agent"
    t.string "referrer"
    t.string "origin"
    t.bigint "memory_usage", default: 0
    t.decimal "cpu_usage", precision: 5, scale: 2, default: "0.0"
    t.jsonb "ip_info", default: "{}"
    t.jsonb "request_headers", default: "{}"
    t.jsonb "response_headers", default: "{}"
    t.integer "status"
    t.integer "response_size"
    t.jsonb "exception", default: "{}"
    t.decimal "elapsed_time", precision: 10, scale: 4, default: "0.0"
    t.uuid "user_id"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["exception"], name: "index_request_logs_on_exception", using: :gin
    t.index ["ip_info"], name: "index_request_logs_on_ip_info", using: :gin
    t.index ["query_params"], name: "index_request_logs_on_query_params", using: :gin
    t.index ["remote_address"], name: "index_request_logs_on_remote_address"
    t.index ["request_headers"], name: "index_request_logs_on_request_headers", using: :gin
    t.index ["response_headers"], name: "index_request_logs_on_response_headers", using: :gin
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

  create_table "user_preferences", primary_key: "user_id", id: :uuid, default: nil, force: :cascade do |t|
    t.string "preferred_locale"
    t.string "preferred_time_zone"
    t.string "preferred_currency"
    t.enum "preferred_color_scheme", enum_type: "color_schemes"
    t.boolean "are_notifications_enabled"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
    t.check_constraint "preferred_color_scheme = ANY (ARRAY['auto'::color_schemes, 'dark'::color_schemes, 'light'::color_schemes])", name: "check_user_preferences_preferred_color_scheme_inclusion"
    t.check_constraint "preferred_color_scheme IS NOT NULL", name: "check_user_preferences_preferred_color_scheme_presence"
    t.check_constraint "preferred_currency IS NOT NULL AND preferred_currency::text <> ''::text", name: "check_user_preferences_preferred_currency_presence"
    t.check_constraint "preferred_locale IS NOT NULL AND preferred_locale::text <> ''::text", name: "check_user_preferences_preferred_locale_presence"
    t.check_constraint "preferred_time_zone IS NOT NULL AND preferred_time_zone::text <> ''::text", name: "check_user_preferences_preferred_time_zone_presence"
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
    t.timestamptz "last_activity_at"
    t.timestamptz "password_updated_at"
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

  create_table "warehouse_managers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "warehouse_id"
    t.uuid "manager_id"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["manager_id"], name: "index_warehouse_managers_on_manager_id"
    t.index ["warehouse_id"], name: "index_warehouse_managers_on_warehouse_id"
  end

  create_table "warehouse_suppliers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "warehouse_id"
    t.uuid "supplier_id"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["supplier_id"], name: "index_warehouse_suppliers_on_supplier_id"
    t.index ["warehouse_id"], name: "index_warehouse_suppliers_on_warehouse_id"
  end

  create_table "warehouses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "reference_code"
    t.string "email_address"
    t.string "contact_number"
    t.text "description"
    t.decimal "total_capacity", precision: 12, scale: 2
    t.string "capacity_unit"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.boolean "is_active", default: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["email_address"], name: "index_warehouses_on_email_address", unique: true
    t.index ["is_active"], name: "index_warehouses_on_is_active"
    t.index ["reference_code"], name: "index_warehouses_on_reference_code", unique: true
    t.check_constraint "capacity_unit IS NOT NULL AND capacity_unit::text <> ''::text", name: "check_warehouses_capacity_unit_presence"
    t.check_constraint "char_length(contact_number::text) <= 55 AND char_length(contact_number::text) >= 2", name: "check_warehouses_contact_number_length"
    t.check_constraint "char_length(description) <= 1000", name: "check_warehouses_description_length"
    t.check_constraint "char_length(email_address::text) <= 55 AND char_length(email_address::text) >= 2", name: "check_warehouses_email_address_length"
    t.check_constraint "char_length(name::text) <= 255 AND char_length(name::text) >= 2", name: "check_warehouses_name_length"
    t.check_constraint "latitude >= '-90'::integer::numeric AND latitude <= 90::numeric", name: "check_warehouses_latitude_range"
    t.check_constraint "longitude >= '-180'::integer::numeric AND longitude <= 180::numeric", name: "check_warehouses_longitude_range"
    t.check_constraint "name IS NOT NULL AND name::text <> ''::text", name: "check_warehouses_name_presence"
    t.check_constraint "total_capacity >= 0::numeric AND total_capacity <= '100000000000'::bigint::numeric", name: "check_warehouses_total_capacity_range"
    t.check_constraint "total_capacity IS NOT NULL", name: "check_warehouses_total_capacity_presence"
  end

  add_foreign_key "request_logs", "users", name: "fk_request_logs_user_id_on_users", on_delete: :nullify
  add_foreign_key "user_details", "users", name: "fk_user_details_user_id_on_users", on_delete: :cascade
  add_foreign_key "user_preferences", "users", name: "fk_user_preferences_user_id_on_users", on_delete: :cascade
  add_foreign_key "users", "roles", name: "fk_users_role_id_on_roles", on_delete: :restrict
  add_foreign_key "warehouse_managers", "users", column: "manager_id", name: "fk_warehouse_managers_manager_id_on_users", on_delete: :restrict
  add_foreign_key "warehouse_managers", "warehouses", name: "fk_warehouse_managers_warehouse_id_on_warehouses", on_delete: :cascade
  add_foreign_key "warehouse_suppliers", "users", column: "supplier_id", name: "fk_warehouse_suppliers_supplier_id_on_users", on_delete: :restrict
  add_foreign_key "warehouse_suppliers", "warehouses", name: "fk_warehouse_suppliers_warehouse_id_on_warehouses", on_delete: :cascade
end
