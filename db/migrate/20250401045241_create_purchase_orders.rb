# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreatePurchaseOrders < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :purchase_orders, id: :uuid do |t|
      t.string :reference_code, index: {using: :btree, unique: true}
      t.references :warehouse,
                   type: :uuid,
                   foreign_key: {
                     to_table: :warehouses,
                     name: :fk_purchase_orders_warehouse_id_on_warehouses,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.references :manager,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_purchase_orders_manager_id_on_users,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.references :supplier,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_purchase_orders_supplier_id_on_users,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.string :reference_document
      t.timestamptz :order_date, index: {using: :btree}, default: -> { "CURRENT_TIMESTAMP" }
      t.date :expected_delivery_date
      t.date :delivered_at
      t.enum :status, enum_type: :purchase_order_statuses, index: {using: :btree}
      t.text :notes
      t.timestamps_with_timezone null: false

      t.check_constraint "CHAR_LENGTH(reference_document) <= 55", name: :check_purchase_orders_reference_document_length

      t.check_constraint "expected_delivery_date >= order_date", name: :check_purchase_orders_expected_delivery_after_order

      t.check_constraint "status IS NOT NULL", name: :check_purchase_orders_status_presence
      t.check_constraint "status IN (#{enum_values('purchase_order_statuses')})", name: :check_purchase_orders_status_in_enum_values

      t.check_constraint "CHAR_LENGTH(notes) <= 1000", name: :check_purchase_orders_notes_length
    end
  end
end
