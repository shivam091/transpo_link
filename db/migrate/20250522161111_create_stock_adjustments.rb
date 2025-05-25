# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateStockAdjustments < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :stock_adjustments, id: :uuid do |t|
      t.references :inventory_batch,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventory_batches,
                     name: :fk_stock_adjustments_inventory_batch_id_on_inventory_batches,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :source,
                   type: :uuid,
                   polymorphic: true,
                   null: true,
                   index: {using: :btree}
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_stock_adjustments_user_id_on_user,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.references :unit,
                   type: :uuid,
                   foreign_key: {
                     to_table: :units,
                     name: :fk_stock_adjustments_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :adjusted_quantity, precision: 12, scale: 2
      t.enum :adjustment_reason, enum_type: :stock_adjustment_reasons, index: {using: :btree}
      t.text :note
      t.timestamptz :adjusted_at, index: {using: :btree}, default: -> { "CURRENT_TIMESTAMP" }
      t.timestamps_with_timezone null: false

      t.check_constraint "adjusted_quantity IS NOT NULL", name: :check_stock_adjustments_adjusted_quantity_presence
      t.check_constraint "adjusted_quantity > 0", name: :check_stock_adjustments_adjusted_quantity_positive

      t.check_constraint "adjustment_reason IS NOT NULL", name: :check_stock_adjustments_adjustment_reason_presence
      t.check_constraint "adjustment_reason IN (#{enum_values('stock_adjustment_reasons')})", name: :check_stock_adjustments_adjustment_reason_in_enum_values

      t.check_constraint "note IS NULL OR CHAR_LENGTH(note) <= 1000", name: :check_stock_adjustments_note_length

      t.check_constraint "adjusted_at IS NOT NULL", name: :check_stock_adjustments_adjusted_at_presence
      t.check_constraint "adjusted_at <= CURRENT_TIMESTAMP", name: :check_stock_adjustments_adjusted_at_not_in_future
    end
  end
end
