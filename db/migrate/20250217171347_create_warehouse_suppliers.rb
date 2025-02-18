# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateWarehouseSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :warehouse_suppliers, id: :uuid do |t|
      t.references :warehouse,
                   type: :uuid,
                   foreign_key: {
                     to_table: :warehouses,
                     name: "fk_warehouse_suppliers_warehouse_id_on_warehouses",
                     on_delete: :cascade
                   },
                   index: {using: "btree"}
      t.references :supplier,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: "fk_warehouse_suppliers_supplier_id_on_users",
                     on_delete: :restrict
                   },
                   index: {using: "btree"}
      t.timestamps_with_timezone null: false
    end
  end
end
