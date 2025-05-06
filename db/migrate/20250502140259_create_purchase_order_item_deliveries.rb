# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreatePurchaseOrderItemDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_order_item_deliveries, id: :uuid do |t|
      t.references :purchase_order_item,
                   type: :uuid,
                   foreign_key: {
                     to_table: :purchase_order_items,
                     name: :fk_purchase_order_item_deliveries_purchase_order_item_id_on_purchase_order_items,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :unit,
                   type: :uuid,
                   foreign_key: {
                     to_table: :units,
                     name: :fk_purchase_order_item_deliveries_unit_id_on_units,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :quantity, precision: 12, scale: 2, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "quantity IS NOT NULL", name: :check_purchase_order_item_deliveries_quantity_presence
      t.check_constraint "quantity > 0.0", name: :check_purchase_order_item_deliveries_quantity_positive
    end
  end
end
