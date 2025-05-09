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
      t.decimal :min_quantity, precision: 12, scale: 2 # Minimum quantity for this price tier
      # Unit of measure for this tier
      t.references :unit,
                   type: :uuid,
                   foreign_key: {
                     to_table: :units,
                     name: :fk_product_prices_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :unit_price, precision: 12, scale: 2 # Price per unit for this tier
      t.string :currency # Currency for this tier
      t.daterange :effective_period, index: {using: :gist} # Date range of validity for this tier
      t.timestamps_with_timezone null: false

      t.index <<~SQL, name: "index_product_prices_on_validity_overlap", using: :gist
        ((product_id)::text),
        currency,
        ((unit_id)::text),
        ((COALESCE(warehouse_id, '00000000-0000-0000-0000-000000000000'::uuid))::text),
        effective_period
      SQL

      t.check_constraint "currency IS NOT NULL AND currency <> ''", name: :check_product_prices_currency_presence

      t.check_constraint "min_quantity IS NOT NULL", name: :check_product_prices_min_quantity_presence
      t.check_constraint "min_quantity > 0.0", name: :check_product_prices_min_quantity_positive

      t.check_constraint "unit_price IS NOT NULL", name: :check_product_prices_unit_price_presence
      t.check_constraint "unit_price > 0.0", name: :check_product_prices_unit_price_positive

      # PostgreSQL automatically enforces this for daterange, but to be explicit
      t.check_constraint "LOWER(effective_period) IS NOT NULL AND UPPER(effective_period) IS NOT NULL", name: :check_product_prices_effective_period_bounds
      t.check_constraint "LOWER(effective_period) < UPPER(effective_period)", name: :check_product_prices_effective_period_order
      # Prevent overlapping price tiers
      t.exclusion_constraint <<~SQL, using: :gist, name: :check_product_prices_no_overlapping_effective_period
        (product_id::text) WITH =,
        (currency) WITH =,
        (unit_id::text) WITH =,
        (coalesce(warehouse_id, '00000000-0000-0000-0000-000000000000')::text) WITH =,
        effective_period WITH &&
      SQL
    end
  end
end
