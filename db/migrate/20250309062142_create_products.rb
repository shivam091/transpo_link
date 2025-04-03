# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products, id: :uuid do |t|
      t.string :reference_code, index: {using: :btree, unique: true}
      t.string :name
      t.text :description
      t.string :sku, index: {using: :btree, unique: true}
      t.string :barcode, index: {using: :btree, unique: true}
      t.decimal :min_stock_threshold, precision: 12, scale: 2, default: 0.0 # For alerts
      t.string :capacity_unit
      t.string :currency
      t.decimal :cost_price, precision: 12, scale: 2, default: 0.0
      t.references :product_category,
                   type: :uuid,
                   foreign_key: {
                     to_table: :product_categories,
                     name: :fk_products_product_category_id_on_product_categories,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.boolean :is_active, default: false, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "name IS NOT NULL AND name <> ''", name: :check_products_name_presence
      t.check_constraint "CHAR_LENGTH(name) <= 255 AND CHAR_LENGTH(name) >= 2", name: :check_products_name_length

      t.check_constraint "CHAR_LENGTH(description) <= 2000", name: :check_products_description_length

      t.check_constraint "sku IS NOT NULL AND sku <> ''", name: :check_products_sku_presence
      t.check_constraint "CHAR_LENGTH(sku) <= 50", name: :check_products_sku_length

      t.check_constraint "min_stock_threshold IS NOT NULL", name: :check_products_min_stock_threshold_presence
      t.check_constraint "min_stock_threshold > 0.0", name: :check_products_min_stock_threshold_positive

      t.check_constraint "capacity_unit IS NOT NULL AND capacity_unit <> ''", name: :check_products_capacity_unit_presence

      t.check_constraint "currency IS NOT NULL AND currency <> ''", name: :check_products_currency_presence

      t.check_constraint "cost_price IS NOT NULL", name: :check_products_cost_price_presence
      t.check_constraint "cost_price > 0.0", name: :check_products_cost_price_positive
    end
  end
end
