# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateUnitConversions < ActiveRecord::Migration[8.0]
  def change
    create_table :unit_conversions, id: :uuid do |t|
      t.references :source_unit,
                   type: :uuid,
                   foreign_key: {
                     to_table: :units,
                     name: :fk_unit_conversions_source_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.references :target_unit,
                   type: :uuid,
                   foreign_key: {
                     to_table: :units,
                     name: :fk_unit_conversions_target_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :multiplier, precision: 30, scale: 15 # e.g., 12 items per pack
      t.timestamps_with_timezone null: false

      t.index [:source_unit_id, :target_unit_id], unique: true

      t.check_constraint "multiplier IS NOT NULL", name: :check_unit_conversions_multiplier_presence
      t.check_constraint "multiplier > 0.0", name: :check_unit_conversions_multiplier_positive
    end
  end
end
