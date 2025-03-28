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

ActiveRecord::Schema[8.0].define(version: 2025_03_23_132952) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "business_categories", ["b2b", "b2c"]
  create_enum "color_schemes", ["auto", "dark", "light"]
  create_enum "entity_types", ["business", "individual"]
  create_enum "movement_types", ["restock", "purchase", "sale", "return", "transfer_in", "transfer_out", "adjustment", "reservation"]
  create_enum "tax_types", ["exclusive", "inclusive"]
  create_enum "tracking_methods", ["fifo", "lifo", "average_cost"]

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

  create_table "feedbacks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "reviewable_type", null: false
    t.uuid "reviewable_id", null: false
    t.decimal "rating", precision: 3, scale: 1
    t.text "comment"
    t.boolean "is_unread", default: true
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.string "reference_code"
    t.index ["is_unread"], name: "index_feedbacks_on_is_unread"
    t.index ["reference_code"], name: "index_feedbacks_on_reference_code", unique: true
    t.index ["reviewable_type", "reviewable_id"], name: "index_feedbacks_on_reviewable"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
    t.check_constraint "(rating * 2::numeric) = floor(rating * 2::numeric)", name: "check_feedbacks_rating_step"
    t.check_constraint "char_length(comment) <= 1000 AND char_length(comment) > 0", name: "check_feedbacks_comment_length"
    t.check_constraint "comment IS NOT NULL AND comment <> ''::text", name: "check_feedbacks_comment_presence"
    t.check_constraint "rating >= 0.0 AND rating <= 10.0", name: "check_feedbacks_rating_numericality"
    t.check_constraint "rating IS NOT NULL", name: "check_feedbacks_rating_presence"
  end

  create_table "inventories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference_code"
    t.uuid "product_id", null: false
    t.uuid "warehouse_id", null: false
    t.string "batch_number"
    t.date "expiration_date"
    t.decimal "stock_quantity", precision: 12, scale: 2, default: "0.0"
    t.decimal "reserved_stock", precision: 12, scale: 2, default: "0.0"
    t.string "inventory_unit"
    t.decimal "cost_price", precision: 12, scale: 2, default: "0.0"
    t.string "currency"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.enum "tracking_method", enum_type: "tracking_methods"
    t.index ["product_id", "warehouse_id"], name: "index_inventories_on_product_id_and_warehouse_id", unique: true
    t.index ["product_id"], name: "index_inventories_on_product_id"
    t.index ["reference_code"], name: "index_inventories_on_reference_code", unique: true
    t.index ["warehouse_id"], name: "index_inventories_on_warehouse_id"
    t.check_constraint "cost_price >= 0.0", name: "check_inventories_cost_price_numericality"
    t.check_constraint "cost_price IS NOT NULL", name: "check_inventories_cost_price_presence"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_inventories_currency_presence"
    t.check_constraint "expiration_date >= CURRENT_DATE", name: "check_inventories_expiration_date_future"
    t.check_constraint "inventory_unit IS NOT NULL AND inventory_unit::text <> ''::text", name: "check_inventories_inventory_unit_presence"
    t.check_constraint "reserved_stock >= 0.0", name: "check_inventories_reserved_stock_numericality"
    t.check_constraint "reserved_stock IS NOT NULL", name: "check_inventories_reserved_stock_presence"
    t.check_constraint "stock_quantity >= 0.0", name: "check_inventories_stock_quantity_numericality"
    t.check_constraint "stock_quantity IS NOT NULL", name: "check_inventories_stock_quantity_presence"
    t.check_constraint "tracking_method = ANY (ARRAY['fifo'::tracking_methods, 'lifo'::tracking_methods, 'average_cost'::tracking_methods])", name: "check_inventories_tracking_method_inclusion"
    t.check_constraint "tracking_method IS NOT NULL", name: "check_inventories_tracking_method_presence"
  end

  create_table "inventory_audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_id", null: false
    t.uuid "inventory_movement_id"
    t.uuid "user_id", null: false
    t.string "movement_type"
    t.decimal "previous_quantity", precision: 12, scale: 2, default: "0.0"
    t.decimal "new_quantity", precision: 12, scale: 2, default: "0.0"
    t.jsonb "metadata", default: "{}"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_id", "movement_type"], name: "index_inventory_audit_logs_on_inventory_id_and_movement_type"
    t.index ["inventory_id"], name: "index_inventory_audit_logs_on_inventory_id"
    t.index ["inventory_movement_id"], name: "index_inventory_audit_logs_on_inventory_movement_id"
    t.index ["metadata"], name: "index_inventory_audit_logs_on_metadata", using: :gin
    t.index ["movement_type"], name: "index_inventory_audit_logs_on_movement_type"
    t.index ["user_id"], name: "index_inventory_audit_logs_on_user_id"
    t.check_constraint "movement_type IS NOT NULL", name: "check_inventory_audit_logs_movement_type_presence"
    t.check_constraint "new_quantity IS NOT NULL", name: "check_inventory_audit_logs_new_quantity_presence"
    t.check_constraint "previous_quantity IS NOT NULL", name: "check_inventory_audit_logs_previous_quantity_presence"
  end

  create_table "inventory_movements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_id", null: false
    t.decimal "quantity", precision: 12, scale: 2, default: "0.0"
    t.enum "movement_type", enum_type: "movement_types"
    t.string "inventory_unit"
    t.decimal "unit_cost", precision: 12, scale: 2
    t.decimal "total_cost", precision: 12, scale: 2
    t.string "currency"
    t.timestamptz "movement_date", default: -> { "now()" }
    t.string "source_type", null: false
    t.uuid "source_id", null: false
    t.jsonb "metadata", default: "{}"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_id", "source_id", "source_type", "movement_type"], name: "idx_on_inventory_id_source_id_source_type_movement__dc133791ed"
    t.index ["inventory_id"], name: "index_inventory_movements_on_inventory_id"
    t.index ["metadata"], name: "index_inventory_movements_on_metadata", using: :gin
    t.index ["source_type", "source_id"], name: "index_inventory_movements_on_source"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_inventory_movements_currency_presence"
    t.check_constraint "inventory_unit IS NOT NULL AND inventory_unit::text <> ''::text", name: "check_inventory_movements_inventory_unit_presence"
    t.check_constraint "movement_type = ANY (ARRAY['restock'::movement_types, 'purchase'::movement_types, 'sale'::movement_types, 'return'::movement_types, 'transfer_in'::movement_types, 'transfer_out'::movement_types, 'adjustment'::movement_types, 'reservation'::movement_types])", name: "check_inventory_movements_movement_type_inclusion"
    t.check_constraint "movement_type IS NOT NULL", name: "check_inventory_movements_movement_type_presence"
    t.check_constraint "quantity <> 0.0", name: "check_inventory_movements_quantity_nonzero"
    t.check_constraint "quantity IS NOT NULL", name: "check_inventory_movements_quantity_presence"
    t.check_constraint "total_cost >= unit_cost", name: "check_inventory_movements_total_cost_numericality"
    t.check_constraint "total_cost IS NOT NULL", name: "check_inventory_movements_total_cost_presence"
    t.check_constraint "unit_cost >= 0.0", name: "check_inventory_movements_unit_cost_numericality"
    t.check_constraint "unit_cost IS NOT NULL", name: "check_inventory_movements_unit_cost_presence"
  end

  create_table "legal_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "country"
    t.enum "entity_type", enum_type: "entity_types"
    t.string "tax_identifier_type"
    t.string "tax_identifier"
    t.string "business_identifier_type"
    t.string "business_identifier"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["business_identifier", "business_identifier_type", "country"], name: "idx_on_business_identifier_business_identifier_type_ce079aa798", unique: true
    t.index ["entity_type"], name: "index_legal_identifiers_on_entity_type"
    t.index ["tax_identifier", "tax_identifier_type", "country", "entity_type"], name: "idx_on_tax_identifier_tax_identifier_type_country_e_6b3ba9dafd", unique: true
    t.index ["user_id"], name: "index_legal_identifiers_on_user_id"
    t.check_constraint "country IS NOT NULL AND country::text <> ''::text", name: "check_legal_identifiers_country_presence"
    t.check_constraint "entity_type = 'business'::entity_types AND business_identifier IS NOT NULL AND business_identifier::text <> ''::text OR entity_type = 'individual'::entity_types AND business_identifier IS NULL", name: "check_legal_identifiers_business_identifier_based_on_entity"
    t.check_constraint "entity_type = 'business'::entity_types AND business_identifier_type IS NOT NULL AND business_identifier_type::text <> ''::text OR entity_type = 'individual'::entity_types AND business_identifier_type IS NULL", name: "check_legal_identifiers_business_identifier_type_based_on_entit"
    t.check_constraint "entity_type = ANY (ARRAY['business'::entity_types, 'individual'::entity_types])", name: "check_legal_identifiers_entity_type_inclusion"
    t.check_constraint "entity_type IS NOT NULL", name: "check_legal_identifiers_entity_type_presence"
    t.check_constraint "tax_identifier IS NOT NULL AND tax_identifier::text <> ''::text", name: "check_legal_identifiers_tax_identifier_presence"
    t.check_constraint "tax_identifier_type IS NOT NULL AND tax_identifier_type::text <> ''::text", name: "check_legal_identifiers_tax_identifier_type_presence"
  end

  create_table "product_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "products_count", default: 0
    t.uuid "parent_category_id"
    t.boolean "is_active", default: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["is_active"], name: "index_product_categories_on_is_active"
    t.index ["name", "parent_category_id"], name: "index_product_categories_on_name_and_parent_category_id", unique: true
    t.index ["parent_category_id"], name: "index_product_categories_on_parent_category_id"
    t.check_constraint "char_length(name::text) <= 255 AND char_length(name::text) >= 2", name: "check_product_categories_name_length"
    t.check_constraint "name IS NOT NULL AND name::text <> ''::text", name: "check_product_categories_name_presence"
  end

  create_table "product_prices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "product_id", null: false
    t.uuid "warehouse_id"
    t.integer "min_quantity", default: 1
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0"
    t.string "currency"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["product_id"], name: "index_product_prices_on_product_id"
    t.index ["warehouse_id"], name: "index_product_prices_on_warehouse_id"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_product_prices_currency_presence"
    t.check_constraint "min_quantity >= 1", name: "check_product_prices_min_quantity_numericality"
    t.check_constraint "min_quantity IS NOT NULL", name: "check_product_prices_min_quantity_presence"
    t.check_constraint "unit_price > 0.0", name: "check_product_prices_unit_price_numericality"
    t.check_constraint "unit_price IS NOT NULL", name: "check_product_prices_unit_price_presence"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference_code"
    t.string "name"
    t.text "description"
    t.string "sku"
    t.string "barcode"
    t.integer "min_stock_threshold", default: 0
    t.string "capacity_unit"
    t.string "currency"
    t.decimal "cost_price", precision: 12, scale: 2, default: "0.0"
    t.uuid "product_category_id", null: false
    t.boolean "is_active", default: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["barcode"], name: "index_products_on_barcode", unique: true
    t.index ["is_active"], name: "index_products_on_is_active"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
    t.index ["reference_code"], name: "index_products_on_reference_code", unique: true
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.check_constraint "capacity_unit IS NOT NULL AND capacity_unit::text <> ''::text", name: "check_products_capacity_unit_presence"
    t.check_constraint "char_length(description) <= 2000", name: "check_products_description_length"
    t.check_constraint "char_length(name::text) <= 255 AND char_length(name::text) >= 2", name: "check_products_name_length"
    t.check_constraint "char_length(sku::text) <= 50", name: "check_products_sku_length"
    t.check_constraint "cost_price > 0.0", name: "check_products_cost_price_numericality"
    t.check_constraint "cost_price IS NOT NULL", name: "check_products_cost_price_presence"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_products_currency_presence"
    t.check_constraint "min_stock_threshold > 0", name: "check_products_min_stock_threshold_numericality"
    t.check_constraint "min_stock_threshold IS NOT NULL", name: "check_products_min_stock_threshold_presence"
    t.check_constraint "name IS NOT NULL AND name::text <> ''::text", name: "check_products_name_presence"
    t.check_constraint "sku IS NOT NULL AND sku::text <> ''::text", name: "check_products_sku_presence"
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

  create_table "tax_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country"
    t.string "tax_identifier_type"
    t.enum "tax_type", enum_type: "tax_types"
    t.enum "business_category", enum_type: "business_categories"
    t.decimal "rate", precision: 5, scale: 2
    t.date "valid_from"
    t.date "valid_to"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["country", "tax_identifier_type"], name: "index_tax_rates_on_country_and_tax_identifier_type"
    t.index ["tax_identifier_type", "country", "tax_type", "business_category", "valid_from"], name: "idx_on_tax_identifier_type_country_tax_type_busines_d6f6f9ae1e", unique: true
    t.index ["tax_type"], name: "index_tax_rates_on_tax_type"
    t.index ["valid_from"], name: "index_tax_rates_on_valid_from"
    t.index ["valid_to"], name: "index_tax_rates_on_valid_to", where: "(valid_to IS NULL)"
    t.check_constraint "business_category = ANY (ARRAY['b2b'::business_categories, 'b2c'::business_categories])", name: "check_tax_rates_business_category_inclusion"
    t.check_constraint "business_category IS NOT NULL", name: "check_tax_rates_business_category_presence"
    t.check_constraint "country IS NOT NULL AND country::text <> ''::text", name: "check_tax_rates_country_presence"
    t.check_constraint "rate >= 0::numeric AND rate <= 100::numeric", name: "check_tax_rates_rate_numericality"
    t.check_constraint "rate IS NOT NULL", name: "check_tax_rates_rate_presence"
    t.check_constraint "tax_identifier_type IS NOT NULL AND tax_identifier_type::text <> ''::text", name: "check_tax_rates_tax_identifier_type_presence"
    t.check_constraint "tax_type = ANY (ARRAY['exclusive'::tax_types, 'inclusive'::tax_types])", name: "check_tax_rates_tax_type_inclusion"
    t.check_constraint "tax_type IS NOT NULL", name: "check_tax_rates_tax_type_presence"
    t.check_constraint "valid_from >= CURRENT_DATE", name: "check_tax_rates_valid_from_future"
    t.check_constraint "valid_from IS NOT NULL", name: "check_tax_rates_valid_from_presence"
    t.check_constraint "valid_to IS NULL OR valid_to > valid_from", name: "check_tax_rates_valid_to_comparison"
  end

  create_table "unit_conversions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "product_id", null: false
    t.string "from_unit"
    t.string "to_unit"
    t.decimal "conversion_rate", precision: 10, scale: 4
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["product_id", "from_unit", "to_unit"], name: "index_unit_conversions_on_product_id_and_from_unit_and_to_unit", unique: true
    t.index ["product_id"], name: "index_unit_conversions_on_product_id"
    t.check_constraint "conversion_rate > 0.0", name: "check_unit_conversions_conversion_rate_numericality"
    t.check_constraint "conversion_rate IS NOT NULL", name: "check_unit_conversions_conversion_rate_presence"
    t.check_constraint "from_unit IS NOT NULL AND from_unit::text <> ''::text", name: "check_unit_conversions_from_unit_presence"
    t.check_constraint "to_unit IS NOT NULL AND to_unit::text <> ''::text", name: "check_unit_conversions_to_unit_presence"
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
    t.uuid "role_id", null: false
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
    t.uuid "warehouse_id", null: false
    t.uuid "manager_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["manager_id"], name: "index_warehouse_managers_on_manager_id"
    t.index ["warehouse_id"], name: "index_warehouse_managers_on_warehouse_id"
  end

  create_table "warehouse_suppliers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "warehouse_id", null: false
    t.uuid "supplier_id", null: false
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

  add_foreign_key "feedbacks", "users", name: "fk_feedbacks_user_id_on_users", on_delete: :nullify
  add_foreign_key "inventories", "products", name: "fk_inventories_product_id_on_products", on_delete: :cascade
  add_foreign_key "inventories", "warehouses", name: "fk_inventories_warehouse_id_on_warehouses", on_delete: :restrict
  add_foreign_key "inventory_audit_logs", "inventories", name: "fk_inventory_audit_logs_inventory_id_on_inventories", on_delete: :cascade
  add_foreign_key "inventory_audit_logs", "inventory_movements", name: "fk_inventory_audit_logs_inventory_movement_id_on_inventory_move", on_delete: :cascade
  add_foreign_key "inventory_audit_logs", "users", name: "fk_inventory_audit_logs_user_id_on_users", on_delete: :nullify
  add_foreign_key "inventory_movements", "inventories", name: "fk_inventory_movements_inventory_id_on_inventories", on_delete: :cascade
  add_foreign_key "legal_identifiers", "users", name: "fk_legal_identifiers_user_id_on_users", on_delete: :cascade
  add_foreign_key "product_categories", "product_categories", column: "parent_category_id", name: "fk_product_categories_parent_category_id_on_product_categories", on_delete: :cascade
  add_foreign_key "product_prices", "products", name: "fk_product_prices_product_id_on_products", on_delete: :cascade
  add_foreign_key "product_prices", "warehouses", name: "fk_product_prices_warehouse_id_on_warehouses", on_delete: :restrict
  add_foreign_key "products", "product_categories", name: "fk_products_product_category_id_on_product_categories", on_delete: :restrict
  add_foreign_key "request_logs", "users", name: "fk_request_logs_user_id_on_users", on_delete: :nullify
  add_foreign_key "unit_conversions", "products", name: "fk_unit_conversions_product_id_on_products", on_delete: :cascade
  add_foreign_key "user_details", "users", name: "fk_user_details_user_id_on_users", on_delete: :cascade
  add_foreign_key "user_preferences", "users", name: "fk_user_preferences_user_id_on_users", on_delete: :cascade
  add_foreign_key "users", "roles", name: "fk_users_role_id_on_roles", on_delete: :restrict
  add_foreign_key "warehouse_managers", "users", column: "manager_id", name: "fk_warehouse_managers_manager_id_on_users", on_delete: :restrict
  add_foreign_key "warehouse_managers", "warehouses", name: "fk_warehouse_managers_warehouse_id_on_warehouses", on_delete: :cascade
  add_foreign_key "warehouse_suppliers", "users", column: "supplier_id", name: "fk_warehouse_suppliers_supplier_id_on_users", on_delete: :restrict
  add_foreign_key "warehouse_suppliers", "warehouses", name: "fk_warehouse_suppliers_warehouse_id_on_warehouses", on_delete: :cascade
end
