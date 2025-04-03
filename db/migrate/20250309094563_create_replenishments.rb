# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateReplenishments < ActiveRecord::Migration[8.0]
  def change
    create_table :replenishments, primary_key: :inventory_id, id: false do |t|
      t.references :inventory,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventories,
                     name: :fk_replenishments_inventory_id_on_inventories,
                     on_delete: :cascade
                   },
                   null: false,
                   primary_key: true,
                   index: {using: :btree, unique: true}
      t.decimal :quantity_pending_from_supplier, precision: 12, scale: 2, default: 0.0 # For purchase orders that are in process
      t.timestamps_with_timezone null: false

      t.check_constraint "quantity_pending_from_supplier IS NOT NULL", name: :check_replenishments_quantity_pending_from_supplier_presence
      t.check_constraint "quantity_pending_from_supplier >= 0.0", name: :check_replenishments_quantity_pending_from_supplier_non_negative
    end
  end
end
