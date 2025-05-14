# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventories < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :inventories, id: :uuid do |t|
      t.string :reference_code, index: {using: :btree, unique: true}
      t.references :product,
                   type: :uuid,
                   foreign_key: {
                     to_table: :products,
                     name: :fk_inventories_product_id_on_products,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :warehouse,
                   type: :uuid,
                   foreign_key: {
                     to_table: :warehouses,
                     name: :fk_inventories_warehouse_id_on_warehouses,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.enum :tracking_method, enum_type: :tracking_methods, index: {using: :btree}
      t.references :unit,
                   type: :uuid,
                   foreign_key: {
                     to_table: :units,
                     name: :fk_inventories_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :average_cost_price, precision: 12, scale: 2, default: 0.0 # Average Cost Price = Σ (Batch Cost Price × Batch Quantity) / Σ Batch Quantity
      t.string :currency
      t.decimal :low_stock_threshold, precision: 12, scale: 2, default: 0.0
      t.timestamps_with_timezone null: false

      t.index [:product_id, :warehouse_id], unique: true

      t.check_constraint "currency IS NOT NULL AND currency <> ''", name: :check_inventories_currency_presence

      t.check_constraint "average_cost_price IS NOT NULL", name: :check_inventories_average_cost_price_presence
      t.check_constraint "average_cost_price >= 0.0", name: :check_inventories_average_cost_price_non_negative

      t.check_constraint "low_stock_threshold IS NOT NULL", name: :check_inventories_low_stock_threshold_presence
      t.check_constraint "low_stock_threshold > 0.0", name: :check_inventories_low_stock_threshold_positive

      t.check_constraint "tracking_method IS NOT NULL", name: :check_inventories_tracking_method_presence
      t.check_constraint "tracking_method IN (#{enum_values('tracking_methods')})", name: :check_inventories_tracking_method_in_enum_values
    end
  end
end
