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
      t.string :lot_number
      t.date :manufactured_at, comment: "Date on which the product in the batch was manufactured"
      t.date :expiration_date, index: {using: :btree}, comment: "Expiry date of the product (Useful for perishable products)"
      t.date :received_at, comment: "Date of which the batch was received into the warehouse"
      t.string :location, comment: "Physical warehouse location, e.g., 'Aisle 3, Rack 2'"
      t.text :notes, comment: "Freeform field for any internal notes"
      t.decimal :quantity, precision: 12, scale: 2, comment: "Quantity of the product in this batch"
      t.references :unit,
                   type: :uuid,
                   comment: "Unit used in this batch",
                   foreign_key: {
                     to_table: :units,
                     name: :fk_inventory_batches_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :cost_price, precision: 12, scale: 2, comment: "Cost per unit"
      t.string :currency, comment: "Currency used in this batch"
      # Polymorphic reference (e.g., purchase_order_item, manual_adjustment, return, etc.)
      t.references :source,
                   type: :uuid,
                   polymorphic: true,
                   null: true,
                   index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.index "inventory_id, batch_number, COALESCE(lot_number, '')", unique: true

      t.check_constraint "batch_number IS NOT NULL AND batch_number <> ''", name: :check_inventory_batches_batch_number_presence
      t.check_constraint "CHAR_LENGTH(batch_number) <= 55", name: :check_inventory_batches_batch_number_length

      t.check_constraint "lot_number IS NULL OR CHAR_LENGTH(lot_number) <= 55", name: :check_inventory_batches_lot_number_length

      t.check_constraint "location IS NOT NULL AND location <> ''", name: :check_inventory_batches_location_presence
      t.check_constraint "CHAR_LENGTH(location) <= 55", name: :check_inventory_batches_location_length

      t.check_constraint "quantity IS NOT NULL", name: :check_inventory_batches_quantity_presence
      t.check_constraint "quantity > 0.0", name: :check_inventory_batches_quantity_positive

      t.check_constraint "cost_price IS NOT NULL", name: :check_inventory_batches_cost_price_presence
      t.check_constraint "cost_price > 0.0", name: :check_inventory_batches_cost_price_positive

      t.check_constraint "currency IS NOT NULL AND currency <> ''", name: :check_inventory_batches_currency_presence

      t.check_constraint "(expiration_date IS NULL OR expiration_date >= CURRENT_DATE)", name: :check_inventory_batches_expiration_future
      t.check_constraint "(manufactured_at IS NULL OR (expiration_date IS NULL OR manufactured_at <= expiration_date))", name: :check_inventory_batches_manufactured_before_expiry
      t.check_constraint "(received_at IS NULL OR manufactured_at IS NULL OR manufactured_at <= received_at)", name: :check_inventory_batches_received_after_manufactured
      t.check_constraint "(lot_number IS NULL OR received_at IS NOT NULL)", name: :check_inventory_batches_received_at_presence

      t.check_constraint "notes IS NULL OR CHAR_LENGTH(notes) <= 1000", name: :check_inventory_batches_notes_length
    end
  end
end
