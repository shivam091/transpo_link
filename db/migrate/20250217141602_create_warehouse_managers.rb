# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateWarehouseManagers < ActiveRecord::Migration[8.0]
  def change
    create_table :warehouse_managers, id: :uuid do |t|
      t.references :warehouse,
                   type: :uuid,
                   foreign_key: {
                     to_table: :warehouses,
                     name: :fk_warehouse_managers_warehouse_id_on_warehouses,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :manager,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_warehouse_managers_manager_id_on_users,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.timestamps_with_timezone null: false
    end
  end
end
