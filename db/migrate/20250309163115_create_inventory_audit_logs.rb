# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_audit_logs, id: :uuid do |t|
      t.references :inventory,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventories,
                     name: :fk_inventory_audit_logs_inventory_id_on_inventories,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :inventory_movement,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventory_movements,
                     name: :fk_inventory_audit_logs_inventory_movement_id_on_inventory_movements,
                     on_delete: :cascade
                   },
                   null: true,
                   index: {using: :btree}
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_inventory_audit_logs_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}

      t.string :movement_type, index: {using: :btree}
      t.integer :previous_quantity
      t.integer :new_quantity
      t.jsonb :metadata, default: "{}", index: {using: :gin}

      t.timestamps_with_timezone null: false

      t.index [:inventory_id, :movement_type], using: :btree

      t.check_constraint "movement_type IS NOT NULL", name: :check_inventory_audit_logs_movement_type_presence

      t.check_constraint "previous_quantity IS NOT NULL", name: :check_inventory_audit_logs_previous_quantity_presence
      t.check_constraint "new_quantity IS NOT NULL", name: :check_inventory_audit_logs_new_quantity_presence
    end
  end
end
