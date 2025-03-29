# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventories < ActiveRecord::Migration[8.0]
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
      t.string :batch_number
      t.date :expiration_date # Useful for perishable products
      t.decimal :stock_quantity, precision: 12, scale: 2, default: 0.0 # Current stock level
      t.decimal :reserved_stock, precision: 12, scale: 2, default: 0.0 # For orders that are in process
      t.string :inventory_unit
      t.decimal :cost_price, precision: 12, scale: 2, default: 0.0 # Procurement cost
      t.string :currency
      t.timestamps_with_timezone null: false

      t.index [:product_id, :warehouse_id], unique: true

      t.check_constraint "currency IS NOT NULL AND currency  <> ''", name: :check_inventories_currency_presence

      t.check_constraint "stock_quantity IS NOT NULL", name: :check_inventories_stock_quantity_presence
      t.check_constraint "stock_quantity >= 0.0", name: :check_inventories_stock_quantity_numericality

      t.check_constraint "reserved_stock IS NOT NULL", name: :check_inventories_reserved_stock_presence
      t.check_constraint "reserved_stock >= 0.0", name: :check_inventories_reserved_stock_numericality

      t.check_constraint "cost_price IS NOT NULL", name: :check_inventories_cost_price_presence
      t.check_constraint "cost_price >= 0.0", name: :check_inventories_cost_price_numericality

      t.check_constraint "inventory_unit IS NOT NULL AND inventory_unit  <> ''", name: :check_inventories_inventory_unit_presence

      t.check_constraint "expiration_date >= CURRENT_DATE", name: :check_inventories_expiration_date_future
    end
  end
end
