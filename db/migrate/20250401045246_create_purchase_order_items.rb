# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreatePurchaseOrderItems < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :purchase_order_items, id: :uuid do |t|
      t.references :purchase_order,
                   type: :uuid,
                   foreign_key: {
                     to_table: :purchase_orders,
                     name: :fk_purchase_order_items_purchase_order_id_on_purchase_orders,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :product,
                   type: :uuid,
                   foreign_key: {
                     to_table: :products,
                     name: :fk_purchase_order_items_product_id_on_products,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :ordered_quantity, precision: 12, scale: 2, default: 0.0, index: {using: :btree}
      t.decimal :received_quantity, precision: 12, scale: 2, default: 0.0, index: {using: :btree}
      t.string :uom
      t.decimal :unit_cost, precision: 12, scale: 2, default: 0.0
      t.decimal :total_cost, precision: 12, scale: 2, as: "ordered_quantity * unit_cost", stored: true
      t.string :currency
      t.enum :status, enum_type: :purchase_order_item_statuses
      t.timestamps_with_timezone null: false

      t.index [:purchase_order_id, :product_id], using: :btree, unique: true

      t.check_constraint "ordered_quantity IS NOT NULL", name: :check_purchase_order_items_ordered_quantity_presence
      t.check_constraint "ordered_quantity > 0.0", name: :check_purchase_order_items_ordered_quantity_positive

      t.check_constraint "received_quantity IS NOT NULL", name: :check_purchase_order_items_received_quantity_presence
      t.check_constraint "received_quantity >= 0.0", name: :check_purchase_order_items_received_quantity_non_negative

      t.check_constraint "uom IS NOT NULL AND uom <> ''", name: :check_purchase_order_items_uom_presence

      t.check_constraint "unit_cost IS NOT NULL", name: :check_purchase_order_items_unit_cost_presence
      t.check_constraint "unit_cost > 0.0", name: :check_purchase_order_items_unit_cost_positive

      t.check_constraint "currency IS NOT NULL AND currency <> ''", name: :check_purchase_order_items_currency_presence

      t.check_constraint "status IS NOT NULL", name: :check_purchase_order_items_status_presence
      t.check_constraint "status IN (#{enum_values('purchase_order_item_statuses')})", name: :check_purchase_order_items_status_in_enum_values
    end
  end
end
