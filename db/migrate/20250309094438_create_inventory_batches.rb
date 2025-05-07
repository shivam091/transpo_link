# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_batches, id: :uuid do |t|
      t.references :inventory,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventories,
                     name: :fk_inventory_batches_inventory_id_on_inventories,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.string :batch_number
      t.date :expiration_date # Useful for perishable products
      t.decimal :quantity, precision: 12, scale: 2 # quantity in this batch
      t.decimal :consumed_quantity, precision: 12, scale: 2, default: 0.0 # Consumed (Restocked) quantity
      t.references :unit,
                   type: :uuid,
                   foreign_key: {
                     to_table: :units,
                     name: :fk_inventory_batches_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree} # Unit used in this batch
      t.decimal :cost_price, precision: 12, scale: 2 # Cost per unit
      t.string :currency # Currency used in this batch
      # Polymorphic reference (e.g., purchase_order_item, manual_adjustment, return, etc.)
      t.references :source,
                   type: :uuid,
                   polymorphic: true,
                   null: true,
                   index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.index [:inventory_id, :batch_number], unique: true

      t.check_constraint "batch_number IS NOT NULL AND batch_number <> ''", name: :check_inventory_batches_batch_number_presence
      t.check_constraint "CHAR_LENGTH(batch_number) <= 55", name: :check_inventory_batches_batch_number_length

      t.check_constraint "quantity IS NOT NULL", name: :check_inventory_batches_quantity_presence
      t.check_constraint "quantity > 0.0", name: :check_inventory_batches_quantity_positive

      t.check_constraint "cost_price IS NOT NULL", name: :check_inventory_batches_cost_price_presence
      t.check_constraint "cost_price > 0.0", name: :check_inventory_batches_cost_price_positive

      t.check_constraint "currency IS NOT NULL AND currency <> ''", name: :check_inventory_batches_currency_presence

      t.check_constraint "expiration_date >= CURRENT_DATE", name: :check_inventory_batches_expiration_date_future
    end
  end
end
