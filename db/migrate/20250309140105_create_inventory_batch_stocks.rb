# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryBatchStocks < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :inventory_batch_stocks, primary_key: :inventory_batch_id, id: false do |t|
      t.references :inventory_batch,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventory_batches,
                     name: :fk_inventory_batch_stocks_inventory_batch_id_on_inventory_batches,
                     on_delete: :cascade
                   },
                   null: false,
                   primary_key: true,
                   index: {using: :btree, unique: true},
                   comment: "Reference to the inventory_batch this stock record belongs to (1:1)"
      t.enum :status, enum_type: :inventory_batch_stock_statuses, index: {using: :btree}, comment: "Status of this batch stock (e.g. available, reserved, exhausted)"
      t.boolean :is_locked, default: false, index: {using: :btree}, comment: "Flag to manually or programmatically lock the batch from further changes"

      # === Quantity Tracking Fields ===
      t.decimal :ordered_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity already ordered by customers from this batch"
      t.decimal :reserved_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity reserved (e.g. for pending orders, QA hold, internal use)"
      t.decimal :damaged_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity marked as damaged and unusable"
      t.decimal :returned_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity returned by customers and deducted from usable stock"
      t.decimal :restocked_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity that has already been restocked (either fully or partially)"
      t.decimal :restockable_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity remaining in the batch that can still be restocked (batch.quantity - restocked_quantity)"
      t.decimal :available_quantity, precision: 12, scale: 2, default: 0.0, comment: "Remaining quantity available to allocate or use from the batch (batch.quantity - used_quantity)"
      t.decimal :adjusted_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity that has been adjusted through manual or system-triggered stock adjustments. This includes changes due to discrepancies, damage, audits, or administrative actions."
      t.decimal :allocated_quantity, precision: 12, scale: 2, default: 0.0, comment: "Quantity allocated from this batch for specific internal operations (e.g. production, kitting, internal transfers). This is distinct from customer orders and reserved quantities."

      # === Virtual columns using SQL expressions ===
      t.decimal :used_quantity, precision: 12, scale: 2,
                as: "ordered_quantity + reserved_quantity + damaged_quantity + returned_quantity + adjusted_quantity + allocated_quantity",
                stored: true,
                comment: "Sum of all non-available usages (ordered + reserved + damaged + returned + adjusted + allocated)"

      t.timestamps_with_timezone null: false

      t.index [:status, :is_locked], using: :btree

      t.check_constraint "ordered_quantity IS NOT NULL", name: :check_inventory_batch_stocks_ordered_quantity_presence
      t.check_constraint "ordered_quantity >= 0.0", name: :check_inventory_batch_stocks_ordered_quantity_non_negative

      t.check_constraint "reserved_quantity IS NOT NULL", name: :check_inventory_batch_stocks_reserved_quantity_presence
      t.check_constraint "reserved_quantity >= 0.0", name: :check_inventory_batch_stocks_reserved_quantity_non_negative

      t.check_constraint "damaged_quantity IS NOT NULL", name: :check_inventory_batch_stocks_damaged_quantity_presence
      t.check_constraint "damaged_quantity >= 0.0", name: :check_inventory_batch_stocks_damaged_quantity_non_negative

      t.check_constraint "returned_quantity IS NOT NULL", name: :check_inventory_batch_stocks_returned_quantity_presence
      t.check_constraint "returned_quantity >= 0.0", name: :check_inventory_batch_stocks_returned_quantity_non_negative

      t.check_constraint "restocked_quantity IS NOT NULL", name: :check_inventory_batch_stocks_restocked_quantity_presence
      t.check_constraint "restocked_quantity >= 0.0", name: :check_inventory_batch_stocks_restocked_quantity_non_negative

      t.check_constraint "restockable_quantity IS NOT NULL", name: :check_inventory_batch_stocks_restockable_quantity_presence
      t.check_constraint "restockable_quantity >= 0.0", name: :check_inventory_batch_stocks_restockable_quantity_non_negative

      t.check_constraint "available_quantity IS NOT NULL", name: :check_inventory_batch_stocks_available_quantity_presence
      t.check_constraint "available_quantity >= 0.0", name: :check_inventory_batch_stocks_available_quantity_non_negative

      t.check_constraint "adjusted_quantity IS NOT NULL", name: :check_inventory_batch_stocks_adjusted_quantity_presence
      t.check_constraint "adjusted_quantity >= 0.0", name: :check_inventory_batch_stocks_adjusted_quantity_non_negative

      t.check_constraint "allocated_quantity IS NOT NULL", name: :check_inventory_batch_stocks_allocated_quantity_presence
      t.check_constraint "allocated_quantity >= 0.0", name: :check_inventory_batch_stocks_allocated_quantity_non_negative

      t.check_constraint "status IS NOT NULL", name: :check_inventory_batch_stocks_status_presence
      t.check_constraint "status IN (#{enum_values('inventory_batch_stock_statuses')})", name: :check_inventory_batch_stocks_status_in_enum_values
    end
  end
end
