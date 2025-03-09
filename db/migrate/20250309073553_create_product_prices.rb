# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateProductPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :product_prices, id: :uuid do |t|
      t.references :product,
                   type: :uuid,
                   foreign_key: {
                     to_table: :products,
                     name: :fk_product_prices_product_id_on_products,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
       # Pricing varies by warehouse
      t.references :warehouse,
                   type: :uuid,
                   foreign_key: {
                     to_table: :warehouses,
                     name: :fk_product_prices_warehouse_id_on_warehouses,
                     on_delete: :restrict
                   },
                   null: true,
                   index: {using: :btree}
      t.integer :min_quantity, default: 1  # Minimum quantity for this price tier
      t.decimal :unit_price, precision: 12, scale: 2, default: 0.0  # Price per unit for this tier
      t.string :currency

      t.timestamps_with_timezone null: false

      t.check_constraint "currency IS NOT NULL AND currency  <> ''", name: :check_product_prices_currency_presence

      t.check_constraint "min_quantity IS NOT NULL", name: :check_product_prices_min_quantity_presence
      t.check_constraint "min_quantity >= 1", name: :check_product_prices_min_quantity_numericality

      t.check_constraint "unit_price IS NOT NULL", name: :check_product_prices_unit_price_presence
      t.check_constraint "unit_price >= 0.0", name: :check_product_prices_unit_price_numericality
    end
  end
end
