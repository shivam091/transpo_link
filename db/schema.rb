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

ActiveRecord::Schema[8.0].define(version: 2025_05_02_140259) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "business_categories", ["b2b", "b2c"]
  create_enum "color_schemes", ["auto", "dark", "light"]
  create_enum "entity_types", ["business", "individual"]
  create_enum "inventory_batch_stock_statuses", ["available", "reserved", "partially_used", "exhausted", "locked", "damaged", "closed"]
  create_enum "legal_identifier_statuses", ["unapproved", "approved", "rejected"]
  create_enum "movement_types", ["restock", "purchase", "sale", "customer_return", "supplier_return", "transfer_in", "transfer_out", "adjustment", "correction", "reservation", "release_reservation", "initial_stock", "inspection", "quarantine", "release_from_quarantine"]
  create_enum "purchase_order_item_statuses", ["pending", "ordered", "partially_delivered", "delivered", "cancelled"]
  create_enum "purchase_order_statuses", ["draft", "submitted", "approved", "partially_delivered", "fully_delivered", "cancelled", "rejected", "closed", "on_hold"]
  create_enum "tax_types", ["exclusive", "inclusive"]
  create_enum "tracking_methods", ["fifo", "lifo", "average_cost"]
  create_enum "unit_categories", ["count", "length", "weight", "area", "volume"]

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "addressable_type", null: false
    t.uuid "addressable_id", null: false
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
    t.string "reference_code"
    t.uuid "user_id", null: false
    t.string "reviewable_type", null: false
    t.uuid "reviewable_id", null: false
    t.decimal "rating", precision: 3, scale: 1
    t.text "comment"
    t.boolean "is_unread", default: true
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["is_unread"], name: "index_feedbacks_on_is_unread"
    t.index ["reference_code"], name: "index_feedbacks_on_reference_code", unique: true
    t.index ["reviewable_type", "reviewable_id"], name: "index_feedbacks_on_reviewable"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
    t.check_constraint "(rating * 2.0) = floor(rating * 2.0)", name: "check_feedbacks_rating_half_step"
    t.check_constraint "char_length(comment) <= 1000 AND char_length(comment) > 0", name: "check_feedbacks_comment_length"
    t.check_constraint "comment IS NOT NULL AND comment <> ''::text", name: "check_feedbacks_comment_presence"
    t.check_constraint "rating >= 0.0 AND rating <= 10.0", name: "check_feedbacks_rating_range"
    t.check_constraint "rating IS NOT NULL", name: "check_feedbacks_rating_presence"
  end

  create_table "inventories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference_code"
    t.uuid "product_id", null: false
    t.uuid "warehouse_id", null: false
    t.enum "tracking_method", enum_type: "tracking_methods"
    t.uuid "unit_id", null: false
    t.decimal "average_cost_price", precision: 12, scale: 2, default: "0.0"
    t.string "currency"
    t.decimal "low_stock_threshold", precision: 12, scale: 2, default: "0.0"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["product_id", "warehouse_id"], name: "index_inventories_on_product_id_and_warehouse_id", unique: true
    t.index ["product_id"], name: "index_inventories_on_product_id"
    t.index ["reference_code"], name: "index_inventories_on_reference_code", unique: true
    t.index ["unit_id"], name: "index_inventories_on_unit_id"
    t.index ["warehouse_id"], name: "index_inventories_on_warehouse_id"
    t.check_constraint "average_cost_price >= 0.0", name: "check_inventories_average_cost_price_non_negative"
    t.check_constraint "average_cost_price IS NOT NULL", name: "check_inventories_average_cost_price_presence"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_inventories_currency_presence"
    t.check_constraint "low_stock_threshold > 0.0", name: "check_inventories_low_stock_threshold_positive"
    t.check_constraint "low_stock_threshold IS NOT NULL", name: "check_inventories_low_stock_threshold_presence"
    t.check_constraint "tracking_method = ANY (ARRAY['fifo'::tracking_methods, 'lifo'::tracking_methods, 'average_cost'::tracking_methods])", name: "check_inventories_tracking_method_in_enum_values"
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

  create_table "inventory_batch_audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_batch_id", null: false
    t.decimal "previous_quantity", precision: 12, scale: 2, default: "0.0"
    t.decimal "new_quantity", precision: 12, scale: 2, default: "0.0"
    t.jsonb "metadata", default: {}
    t.uuid "user_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_batch_id", "user_id"], name: "idx_on_inventory_batch_id_user_id_a136d8f767"
    t.index ["inventory_batch_id"], name: "index_inventory_batch_audit_logs_on_inventory_batch_id"
    t.index ["metadata"], name: "index_inventory_batch_audit_logs_on_metadata", using: :gin
    t.index ["user_id"], name: "index_inventory_batch_audit_logs_on_user_id"
    t.check_constraint "new_quantity IS NOT NULL", name: "check_inventory_batch_audit_logs_new_quantity_presence"
    t.check_constraint "previous_quantity IS NOT NULL", name: "check_inventory_batch_audit_logs_previous_quantity_presence"
  end

  create_table "inventory_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_id", null: false
    t.string "batch_number"
    t.date "expiration_date"
    t.decimal "quantity", precision: 12, scale: 2
    t.uuid "unit_id", null: false
    t.decimal "cost_price", precision: 12, scale: 2
    t.string "currency"
    t.string "source_type"
    t.uuid "source_id"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_id", "batch_number"], name: "index_inventory_batches_on_inventory_id_and_batch_number", unique: true
    t.index ["inventory_id"], name: "index_inventory_batches_on_inventory_id"
    t.index ["source_type", "source_id"], name: "index_inventory_batches_on_source"
    t.index ["unit_id"], name: "index_inventory_batches_on_unit_id"
    t.check_constraint "batch_number IS NOT NULL AND batch_number::text <> ''::text", name: "check_inventory_batches_batch_number_presence"
    t.check_constraint "char_length(batch_number::text) <= 55", name: "check_inventory_batches_batch_number_length"
    t.check_constraint "cost_price > 0.0", name: "check_inventory_batches_cost_price_positive"
    t.check_constraint "cost_price IS NOT NULL", name: "check_inventory_batches_cost_price_presence"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_inventory_batches_currency_presence"
    t.check_constraint "expiration_date >= CURRENT_DATE", name: "check_inventory_batches_expiration_date_future"
    t.check_constraint "quantity > 0.0", name: "check_inventory_batches_quantity_positive"
    t.check_constraint "quantity IS NOT NULL", name: "check_inventory_batches_quantity_presence"
  end

  create_table "inventory_movements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_id", null: false
    t.decimal "quantity", precision: 12, scale: 2, default: "0.0"
    t.enum "movement_type", enum_type: "movement_types"
    t.uuid "unit_id", null: false
    t.decimal "unit_cost", precision: 12, scale: 2
    t.decimal "total_cost", precision: 12, scale: 2
    t.string "currency"
    t.timestamptz "movement_date", default: -> { "CURRENT_TIMESTAMP" }
    t.string "source_type", null: false
    t.uuid "source_id", null: false
    t.jsonb "metadata", default: "{}"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_id", "source_id", "source_type", "movement_type"], name: "idx_on_inventory_id_source_id_source_type_movement__dc133791ed"
    t.index ["inventory_id"], name: "index_inventory_movements_on_inventory_id"
    t.index ["metadata"], name: "index_inventory_movements_on_metadata", using: :gin
    t.index ["source_type", "source_id"], name: "index_inventory_movements_on_source"
    t.index ["unit_id"], name: "index_inventory_movements_on_unit_id"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_inventory_movements_currency_presence"
    t.check_constraint "movement_type = ANY (ARRAY['restock'::movement_types, 'purchase'::movement_types, 'sale'::movement_types, 'customer_return'::movement_types, 'supplier_return'::movement_types, 'transfer_in'::movement_types, 'transfer_out'::movement_types, 'adjustment'::movement_types, 'correction'::movement_types, 'reservation'::movement_types, 'release_reservation'::movement_types, 'initial_stock'::movement_types, 'inspection'::movement_types, 'quarantine'::movement_types, 'release_from_quarantine'::movement_types])", name: "check_inventory_movements_movement_type_in_enum_values"
    t.check_constraint "movement_type IS NOT NULL", name: "check_inventory_movements_movement_type_presence"
    t.check_constraint "quantity <> 0.0", name: "check_inventory_movements_quantity_nonzero"
    t.check_constraint "quantity IS NOT NULL", name: "check_inventory_movements_quantity_presence"
    t.check_constraint "total_cost >= unit_cost", name: "check_inventory_movements_total_cost_gteq_unit_cost"
    t.check_constraint "total_cost IS NOT NULL", name: "check_inventory_movements_total_cost_presence"
    t.check_constraint "unit_cost > 0.0", name: "check_inventory_movements_unit_cost_positive"
    t.check_constraint "unit_cost IS NOT NULL", name: "check_inventory_movements_unit_cost_presence"
  end

  create_table "inventory_restocks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_batch_id", null: false
    t.uuid "unit_id", null: false
    t.decimal "quantity", precision: 12, scale: 2
    t.text "comment"
    t.text "note"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_batch_id"], name: "index_inventory_restocks_on_inventory_batch_id"
    t.index ["unit_id"], name: "index_inventory_restocks_on_unit_id"
    t.check_constraint "char_length(comment) <= 1000 AND char_length(comment) > 0", name: "check_inventory_restocks_comment_length"
    t.check_constraint "char_length(note) <= 1000", name: "check_inventory_restocks_note_length"
    t.check_constraint "comment IS NOT NULL AND comment <> ''::text", name: "check_inventory_restocks_comment_presence"
    t.check_constraint "quantity > 0.0", name: "check_inventory_restocks_quantity_positive"
    t.check_constraint "quantity IS NOT NULL", name: "check_inventory_restocks_quantity_presence"
  end

  create_table "legal_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "country"
    t.enum "entity_type", enum_type: "entity_types"
    t.string "tax_identifier_type"
    t.string "tax_identifier"
    t.string "business_identifier_type"
    t.string "business_identifier"
    t.enum "status", enum_type: "legal_identifier_statuses"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["business_identifier", "business_identifier_type", "country"], name: "idx_on_business_identifier_business_identifier_type_ce079aa798", unique: true
    t.index ["entity_type"], name: "index_legal_identifiers_on_entity_type"
    t.index ["status"], name: "index_legal_identifiers_on_status"
    t.index ["tax_identifier", "tax_identifier_type", "country", "entity_type"], name: "idx_on_tax_identifier_tax_identifier_type_country_e_6b3ba9dafd", unique: true
    t.index ["user_id"], name: "index_legal_identifiers_on_user_id"
    t.check_constraint "country IS NOT NULL AND country::text <> ''::text", name: "check_legal_identifiers_country_presence"
    t.check_constraint "entity_type = 'business'::entity_types AND business_identifier IS NOT NULL AND business_identifier::text <> ''::text OR entity_type = 'individual'::entity_types AND business_identifier IS NULL", name: "check_legal_identifiers_bi_presence_based_on_entity"
    t.check_constraint "entity_type = 'business'::entity_types AND business_identifier_type IS NOT NULL AND business_identifier_type::text <> ''::text OR entity_type = 'individual'::entity_types AND business_identifier_type IS NULL", name: "check_legal_identifiers_bi_type_presence_based_on_entity"
    t.check_constraint "entity_type = ANY (ARRAY['business'::entity_types, 'individual'::entity_types])", name: "check_legal_identifiers_entity_type_in_enum_values"
    t.check_constraint "entity_type IS NOT NULL", name: "check_legal_identifiers_entity_type_presence"
    t.check_constraint "status = ANY (ARRAY['unapproved'::legal_identifier_statuses, 'approved'::legal_identifier_statuses, 'rejected'::legal_identifier_statuses])", name: "check_legal_identifiers_status_in_enum_values"
    t.check_constraint "status IS NOT NULL", name: "check_legal_identifiers_status_presence"
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
    t.decimal "min_quantity", precision: 12, scale: 2
    t.uuid "unit_id", null: false
    t.decimal "unit_price", precision: 12, scale: 2
    t.string "currency"
    t.daterange "effective_period"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index "((product_id)::text), currency, min_quantity, ((unit_id)::text), ((COALESCE(warehouse_id, '00000000-0000-0000-0000-000000000000'::uuid))::text), effective_period", name: "index_product_prices_on_validity_overlap", using: :gist
    t.index ["effective_period"], name: "index_product_prices_on_effective_period", using: :gist
    t.index ["product_id"], name: "index_product_prices_on_product_id"
    t.index ["unit_id"], name: "index_product_prices_on_unit_id"
    t.index ["warehouse_id"], name: "index_product_prices_on_warehouse_id"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_product_prices_currency_presence"
    t.check_constraint "lower(effective_period) < upper(effective_period)", name: "check_product_prices_effective_period_order"
    t.check_constraint "lower(effective_period) IS NOT NULL AND upper(effective_period) IS NOT NULL", name: "check_product_prices_effective_period_bounds"
    t.check_constraint "min_quantity > 0.0", name: "check_product_prices_min_quantity_positive"
    t.check_constraint "min_quantity IS NOT NULL", name: "check_product_prices_min_quantity_presence"
    t.check_constraint "unit_price > 0.0", name: "check_product_prices_unit_price_positive"
    t.check_constraint "unit_price IS NOT NULL", name: "check_product_prices_unit_price_presence"
    t.exclusion_constraint "((product_id)::text) WITH =, currency WITH =, min_quantity WITH =, ((unit_id)::text) WITH =, ((COALESCE(warehouse_id, '00000000-0000-0000-0000-000000000000'::uuid))::text) WITH =, effective_period WITH &&", using: :gist, name: "check_product_prices_no_overlapping_effective_period"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference_code"
    t.string "name"
    t.text "description"
    t.string "sku"
    t.string "barcode"
    t.decimal "min_stock_threshold", precision: 12, scale: 2, default: "10.0"
    t.uuid "unit_id", null: false
    t.string "currency"
    t.decimal "cost_price", precision: 12, scale: 2
    t.uuid "product_category_id", null: false
    t.boolean "is_active", default: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["barcode"], name: "index_products_on_barcode", unique: true
    t.index ["is_active"], name: "index_products_on_is_active"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
    t.index ["reference_code"], name: "index_products_on_reference_code", unique: true
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["unit_id"], name: "index_products_on_unit_id"
    t.check_constraint "char_length(description) <= 2000", name: "check_products_description_length"
    t.check_constraint "char_length(name::text) <= 255 AND char_length(name::text) >= 2", name: "check_products_name_length"
    t.check_constraint "char_length(sku::text) <= 50", name: "check_products_sku_length"
    t.check_constraint "cost_price > 0.0", name: "check_products_cost_price_positive"
    t.check_constraint "cost_price IS NOT NULL", name: "check_products_cost_price_presence"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_products_currency_presence"
    t.check_constraint "min_stock_threshold > 0.0", name: "check_products_min_stock_threshold_positive"
    t.check_constraint "min_stock_threshold IS NOT NULL", name: "check_products_min_stock_threshold_presence"
    t.check_constraint "name IS NOT NULL AND name::text <> ''::text", name: "check_products_name_presence"
    t.check_constraint "sku IS NOT NULL AND sku::text <> ''::text", name: "check_products_sku_presence"
  end

  create_table "purchase_order_item_deliveries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "purchase_order_item_id", null: false
    t.uuid "unit_id", null: false
    t.decimal "quantity", precision: 12, scale: 2
    t.text "comment"
    t.text "note"
    t.string "reference_document"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["purchase_order_item_id"], name: "index_purchase_order_item_deliveries_on_purchase_order_item_id"
    t.index ["unit_id"], name: "index_purchase_order_item_deliveries_on_unit_id"
    t.check_constraint "char_length(comment) <= 1000 AND char_length(comment) > 0", name: "check_purchase_order_item_deliveries_comment_length"
    t.check_constraint "char_length(note) <= 1000", name: "check_purchase_order_item_deliveries_note_length"
    t.check_constraint "char_length(reference_document::text) <= 55", name: "check_purchase_order_item_deliveries_reference_document_length"
    t.check_constraint "comment IS NOT NULL AND comment <> ''::text", name: "check_purchase_order_item_deliveries_comment_presence"
    t.check_constraint "quantity > 0.0", name: "check_purchase_order_item_deliveries_quantity_positive"
    t.check_constraint "quantity IS NOT NULL", name: "check_purchase_order_item_deliveries_quantity_presence"
  end

  create_table "purchase_order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "purchase_order_id", null: false
    t.uuid "product_id", null: false
    t.decimal "quantity", precision: 12, scale: 2
    t.decimal "received_quantity", precision: 12, scale: 2, default: "0.0"
    t.uuid "unit_id", null: false
    t.decimal "unit_cost", precision: 12, scale: 2
    t.virtual "total_cost", type: :decimal, precision: 12, scale: 2, as: "(quantity * unit_cost)", stored: true
    t.string "currency"
    t.enum "status", enum_type: "purchase_order_item_statuses"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id", "product_id"], name: "index_purchase_order_items_on_purchase_order_id_and_product_id", unique: true
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
    t.index ["quantity"], name: "index_purchase_order_items_on_quantity"
    t.index ["received_quantity"], name: "index_purchase_order_items_on_received_quantity"
    t.index ["unit_id"], name: "index_purchase_order_items_on_unit_id"
    t.check_constraint "currency IS NOT NULL AND currency::text <> ''::text", name: "check_purchase_order_items_currency_presence"
    t.check_constraint "quantity > 0.0", name: "check_purchase_order_items_quantity_positive"
    t.check_constraint "quantity IS NOT NULL", name: "check_purchase_order_items_quantity_presence"
    t.check_constraint "received_quantity >= 0.0", name: "check_purchase_order_items_received_quantity_non_negative"
    t.check_constraint "received_quantity IS NOT NULL", name: "check_purchase_order_items_received_quantity_presence"
    t.check_constraint "status = ANY (ARRAY['pending'::purchase_order_item_statuses, 'ordered'::purchase_order_item_statuses, 'partially_delivered'::purchase_order_item_statuses, 'delivered'::purchase_order_item_statuses, 'cancelled'::purchase_order_item_statuses])", name: "check_purchase_order_items_status_in_enum_values"
    t.check_constraint "status IS NOT NULL", name: "check_purchase_order_items_status_presence"
    t.check_constraint "unit_cost > 0.0", name: "check_purchase_order_items_unit_cost_positive"
    t.check_constraint "unit_cost IS NOT NULL", name: "check_purchase_order_items_unit_cost_presence"
  end

  create_table "purchase_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference_code"
    t.uuid "warehouse_id", null: false
    t.uuid "manager_id", null: false
    t.uuid "supplier_id", null: false
    t.string "reference_document"
    t.timestamptz "order_date", default: -> { "CURRENT_TIMESTAMP" }
    t.date "expected_delivery_date"
    t.date "actual_delivery_date"
    t.enum "status", enum_type: "purchase_order_statuses"
    t.text "notes"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["manager_id"], name: "index_purchase_orders_on_manager_id"
    t.index ["order_date"], name: "index_purchase_orders_on_order_date"
    t.index ["reference_code"], name: "index_purchase_orders_on_reference_code", unique: true
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["warehouse_id"], name: "index_purchase_orders_on_warehouse_id"
    t.check_constraint "char_length(notes) <= 1000", name: "check_purchase_orders_notes_length"
    t.check_constraint "char_length(reference_document::text) <= 55", name: "check_purchase_orders_reference_document_length"
    t.check_constraint "expected_delivery_date >= order_date", name: "check_purchase_orders_expected_delivery_after_order"
    t.check_constraint "status = ANY (ARRAY['draft'::purchase_order_statuses, 'submitted'::purchase_order_statuses, 'approved'::purchase_order_statuses, 'partially_delivered'::purchase_order_statuses, 'fully_delivered'::purchase_order_statuses, 'cancelled'::purchase_order_statuses, 'rejected'::purchase_order_statuses, 'closed'::purchase_order_statuses, 'on_hold'::purchase_order_statuses])", name: "check_purchase_orders_status_in_enum_values"
    t.check_constraint "status IS NOT NULL", name: "check_purchase_orders_status_presence"
  end

  create_table "replenishments", primary_key: "inventory_id", id: :uuid, default: nil, force: :cascade do |t|
    t.decimal "quantity_pending_from_supplier", precision: 12, scale: 2, default: "0.0"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_id"], name: "index_replenishments_on_inventory_id", unique: true
    t.check_constraint "quantity_pending_from_supplier >= 0.0", name: "check_replenishments_quantity_pending_from_supplier_non_negativ"
    t.check_constraint "quantity_pending_from_supplier IS NOT NULL", name: "check_replenishments_quantity_pending_from_supplier_presence"
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
    t.check_constraint "upper(method::text) = method::text", name: "check_request_logs_method_in_uppercase"
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

  create_table "stocks", primary_key: "inventory_id", id: :uuid, default: nil, force: :cascade do |t|
    t.decimal "quantity_in_hand", precision: 12, scale: 2, default: "0.0"
    t.decimal "quantity_pending_to_buyer", precision: 12, scale: 2, default: "0.0"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["inventory_id"], name: "index_stocks_on_inventory_id", unique: true
    t.check_constraint "quantity_in_hand >= 0.0", name: "check_stocks_quantity_in_hand_non_negative"
    t.check_constraint "quantity_in_hand IS NOT NULL", name: "check_stocks_quantity_in_hand_presence"
    t.check_constraint "quantity_pending_to_buyer >= 0.0", name: "check_stocks_quantity_pending_to_buyer_non_negative"
    t.check_constraint "quantity_pending_to_buyer IS NOT NULL", name: "check_stocks_quantity_pending_to_buyer_presence"
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
    t.check_constraint "business_category = ANY (ARRAY['b2b'::business_categories, 'b2c'::business_categories])", name: "check_tax_rates_business_category_in_enum_values"
    t.check_constraint "business_category IS NOT NULL", name: "check_tax_rates_business_category_presence"
    t.check_constraint "country IS NOT NULL AND country::text <> ''::text", name: "check_tax_rates_country_presence"
    t.check_constraint "rate >= 0.0 AND rate <= 100.0", name: "check_tax_rates_rate_range"
    t.check_constraint "rate IS NOT NULL", name: "check_tax_rates_rate_presence"
    t.check_constraint "tax_identifier_type IS NOT NULL AND tax_identifier_type::text <> ''::text", name: "check_tax_rates_tax_identifier_type_presence"
    t.check_constraint "tax_type = ANY (ARRAY['exclusive'::tax_types, 'inclusive'::tax_types])", name: "check_tax_rates_tax_type_in_enum_values"
    t.check_constraint "tax_type IS NOT NULL", name: "check_tax_rates_tax_type_presence"
    t.check_constraint "valid_from >= CURRENT_DATE", name: "check_tax_rates_valid_from_today_or_in_future"
    t.check_constraint "valid_from IS NOT NULL", name: "check_tax_rates_valid_from_presence"
    t.check_constraint "valid_to IS NULL OR valid_to > valid_from", name: "check_tax_rates_valid_to_after_valid_from"
  end

  create_table "unit_conversions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "source_unit_id", null: false
    t.uuid "target_unit_id", null: false
    t.decimal "multiplier", precision: 30, scale: 15
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["source_unit_id", "target_unit_id"], name: "index_unit_conversions_on_source_unit_id_and_target_unit_id", unique: true
    t.index ["source_unit_id"], name: "index_unit_conversions_on_source_unit_id"
    t.index ["target_unit_id"], name: "index_unit_conversions_on_target_unit_id"
    t.check_constraint "multiplier > 0.0", name: "check_unit_conversions_multiplier_positive"
    t.check_constraint "multiplier IS NOT NULL", name: "check_unit_conversions_multiplier_presence"
  end

  create_table "units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "category", enum_type: "unit_categories"
    t.string "symbol"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["category", "symbol"], name: "index_units_on_category_and_symbol", unique: true
    t.index ["category"], name: "index_units_on_category"
    t.check_constraint "category = ANY (ARRAY['count'::unit_categories, 'length'::unit_categories, 'weight'::unit_categories, 'area'::unit_categories, 'volume'::unit_categories])", name: "check_units_category_in_enum_values"
    t.check_constraint "category IS NOT NULL", name: "check_units_category_presence"
    t.check_constraint "symbol IS NOT NULL AND symbol::text <> ''::text", name: "check_units_symbol_presence"
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
    t.string "preferred_date_format"
    t.string "preferred_time_format"
    t.string "preferred_datetime_format"
    t.string "first_day_of_week"
    t.boolean "are_notifications_enabled"
    t.boolean "enable_keyboard_shortcuts"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
    t.check_constraint "first_day_of_week IS NOT NULL", name: "check_user_preferences_first_day_of_week_presence"
    t.check_constraint "preferred_color_scheme = ANY (ARRAY['auto'::color_schemes, 'dark'::color_schemes, 'light'::color_schemes])", name: "check_user_preferences_preferred_color_scheme_in_enum_values"
    t.check_constraint "preferred_color_scheme IS NOT NULL", name: "check_user_preferences_preferred_color_scheme_presence"
    t.check_constraint "preferred_currency IS NOT NULL AND preferred_currency::text <> ''::text", name: "check_user_preferences_preferred_currency_presence"
    t.check_constraint "preferred_date_format IS NOT NULL", name: "check_user_preferences_preferred_date_format_presence"
    t.check_constraint "preferred_datetime_format IS NOT NULL", name: "check_user_preferences_preferred_datetime_format_presence"
    t.check_constraint "preferred_locale IS NOT NULL AND preferred_locale::text <> ''::text", name: "check_user_preferences_preferred_locale_presence"
    t.check_constraint "preferred_time_format IS NOT NULL", name: "check_user_preferences_preferred_time_format_presence"
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
    t.timestamptz "last_activity_at"
    t.timestamptz "password_updated_at"
    t.boolean "is_active", default: false
    t.boolean "is_banned", default: false
    t.uuid "role_id", null: false
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
    t.decimal "total_capacity", precision: 15, scale: 4
    t.uuid "unit_id", null: false
    t.decimal "latitude", precision: 15, scale: 13
    t.decimal "longitude", precision: 15, scale: 12
    t.boolean "is_active", default: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["email_address"], name: "index_warehouses_on_email_address", unique: true
    t.index ["is_active"], name: "index_warehouses_on_is_active"
    t.index ["reference_code"], name: "index_warehouses_on_reference_code", unique: true
    t.index ["unit_id"], name: "index_warehouses_on_unit_id"
    t.check_constraint "char_length(contact_number::text) <= 55 AND char_length(contact_number::text) >= 2", name: "check_warehouses_contact_number_length"
    t.check_constraint "char_length(description) <= 1000", name: "check_warehouses_description_length"
    t.check_constraint "char_length(email_address::text) <= 55 AND char_length(email_address::text) >= 2", name: "check_warehouses_email_address_length"
    t.check_constraint "char_length(name::text) <= 255 AND char_length(name::text) >= 2", name: "check_warehouses_name_length"
    t.check_constraint "latitude >= '-90.0'::numeric AND latitude <= 90.0", name: "check_warehouses_latitude_range"
    t.check_constraint "longitude >= '-180.0'::numeric AND longitude <= 180.0", name: "check_warehouses_longitude_range"
    t.check_constraint "name IS NOT NULL AND name::text <> ''::text", name: "check_warehouses_name_presence"
    t.check_constraint "total_capacity > 0.0 AND total_capacity < 100000000000.0", name: "check_warehouses_total_capacity_range"
    t.check_constraint "total_capacity IS NOT NULL", name: "check_warehouses_total_capacity_presence"
  end

  add_foreign_key "feedbacks", "users", name: "fk_feedbacks_user_id_on_users", on_delete: :nullify
  add_foreign_key "inventories", "products", name: "fk_inventories_product_id_on_products", on_delete: :cascade
  add_foreign_key "inventories", "units", name: "fk_inventories_unit_id_on_units", on_delete: :restrict
  add_foreign_key "inventories", "warehouses", name: "fk_inventories_warehouse_id_on_warehouses", on_delete: :restrict
  add_foreign_key "inventory_audit_logs", "inventories", name: "fk_inventory_audit_logs_inventory_id_on_inventories", on_delete: :cascade
  add_foreign_key "inventory_audit_logs", "inventory_movements", name: "fk_inventory_audit_logs_inventory_movement_id_on_inventory_move", on_delete: :cascade
  add_foreign_key "inventory_audit_logs", "users", name: "fk_inventory_audit_logs_user_id_on_users", on_delete: :nullify
  add_foreign_key "inventory_batch_audit_logs", "inventory_batches", name: "fk_inventory_batch_audit_logs_inventory_batch_id_on_inventory_b", on_delete: :nullify
  add_foreign_key "inventory_batch_audit_logs", "users", name: "fk_inventory_batch_audit_logs_user_id_on_users", on_delete: :nullify
  add_foreign_key "inventory_batches", "inventories", name: "fk_inventory_batches_inventory_id_on_inventories", on_delete: :cascade
  add_foreign_key "inventory_batches", "units", name: "fk_inventory_batches_unit_id_on_units", on_delete: :restrict
  add_foreign_key "inventory_movements", "inventories", name: "fk_inventory_movements_inventory_id_on_inventories", on_delete: :cascade
  add_foreign_key "inventory_movements", "units", name: "fk_inventory_movements_unit_id_on_units", on_delete: :restrict
  add_foreign_key "inventory_restocks", "inventory_batches", name: "fk_inventory_restocks_inventory_batch_id_on_inventory_batches", on_delete: :cascade
  add_foreign_key "inventory_restocks", "units", name: "fk_inventory_restocks_unit_id_on_units", on_delete: :restrict
  add_foreign_key "legal_identifiers", "users", name: "fk_legal_identifiers_user_id_on_users", on_delete: :cascade
  add_foreign_key "product_categories", "product_categories", column: "parent_category_id", name: "fk_product_categories_parent_category_id_on_product_categories", on_delete: :cascade
  add_foreign_key "product_prices", "products", name: "fk_product_prices_product_id_on_products", on_delete: :cascade
  add_foreign_key "product_prices", "units", name: "fk_product_prices_unit_id_on_units", on_delete: :restrict
  add_foreign_key "product_prices", "warehouses", name: "fk_product_prices_warehouse_id_on_warehouses", on_delete: :restrict
  add_foreign_key "products", "product_categories", name: "fk_products_product_category_id_on_product_categories", on_delete: :restrict
  add_foreign_key "products", "units", name: "fk_products_unit_id_on_units", on_delete: :restrict
  add_foreign_key "purchase_order_item_deliveries", "purchase_order_items", name: "fk_purchase_order_item_deliveries_purchase_order_item_id_on_pur", on_delete: :cascade
  add_foreign_key "purchase_order_item_deliveries", "units", name: "fk_purchase_order_item_deliveries_unit_id_on_units", on_delete: :restrict
  add_foreign_key "purchase_order_items", "products", name: "fk_purchase_order_items_product_id_on_products", on_delete: :restrict
  add_foreign_key "purchase_order_items", "purchase_orders", name: "fk_purchase_order_items_purchase_order_id_on_purchase_orders", on_delete: :cascade
  add_foreign_key "purchase_order_items", "units", name: "fk_purchase_order_items_unit_id_on_units", on_delete: :restrict
  add_foreign_key "purchase_orders", "users", column: "manager_id", name: "fk_purchase_orders_manager_id_on_users", on_delete: :restrict
  add_foreign_key "purchase_orders", "users", column: "supplier_id", name: "fk_purchase_orders_supplier_id_on_users", on_delete: :restrict
  add_foreign_key "purchase_orders", "warehouses", name: "fk_purchase_orders_warehouse_id_on_warehouses", on_delete: :restrict
  add_foreign_key "replenishments", "inventories", name: "fk_replenishments_inventory_id_on_inventories", on_delete: :cascade
  add_foreign_key "request_logs", "users", name: "fk_request_logs_user_id_on_users", on_delete: :nullify
  add_foreign_key "stocks", "inventories", name: "fk_stocks_inventory_id_on_inventories", on_delete: :cascade
  add_foreign_key "unit_conversions", "units", column: "source_unit_id", name: "fk_unit_conversions_source_unit_id_on_units", on_delete: :restrict
  add_foreign_key "unit_conversions", "units", column: "target_unit_id", name: "fk_unit_conversions_target_unit_id_on_units", on_delete: :restrict
  add_foreign_key "user_details", "users", name: "fk_user_details_user_id_on_users", on_delete: :cascade
  add_foreign_key "user_preferences", "users", name: "fk_user_preferences_user_id_on_users", on_delete: :cascade
  add_foreign_key "users", "roles", name: "fk_users_role_id_on_roles", on_delete: :restrict
  add_foreign_key "warehouse_managers", "users", column: "manager_id", name: "fk_warehouse_managers_manager_id_on_users", on_delete: :restrict
  add_foreign_key "warehouse_managers", "warehouses", name: "fk_warehouse_managers_warehouse_id_on_warehouses", on_delete: :cascade
  add_foreign_key "warehouse_suppliers", "users", column: "supplier_id", name: "fk_warehouse_suppliers_supplier_id_on_users", on_delete: :restrict
  add_foreign_key "warehouse_suppliers", "warehouses", name: "fk_warehouse_suppliers_warehouse_id_on_warehouses", on_delete: :cascade
  add_foreign_key "warehouses", "units", name: "fk_warehouses_unit_id_on_units", on_delete: :restrict
end
