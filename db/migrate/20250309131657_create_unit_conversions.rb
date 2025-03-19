# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateUnitConversions < ActiveRecord::Migration[8.0]
  def change
    create_table :unit_conversions, id: :uuid do |t|
      t.references :product,
                   type: :uuid,
                   foreign_key: {
                     to_table: :products,
                     name: :fk_unit_conversions_product_id_on_products,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.string :from_unit # e.g., item
      t.string :to_unit # e.g., pack
      t.decimal :conversion_rate, precision: 10, scale: 4 # e.g., 12 items per pack
      t.timestamps_with_timezone null: false

      t.index [:product_id, :from_unit, :to_unit], unique: true

      t.check_constraint "from_unit IS NOT NULL AND from_unit  <> ''", name: :check_unit_conversions_from_unit_presence
      t.check_constraint "to_unit IS NOT NULL AND to_unit  <> ''", name: :check_unit_conversions_to_unit_presence

      t.check_constraint "conversion_rate IS NOT NULL", name: :check_unit_conversions_conversion_rate_presence
      t.check_constraint "conversion_rate > 0.0", name: :check_unit_conversions_conversion_rate_numericality
    end
  end
end
