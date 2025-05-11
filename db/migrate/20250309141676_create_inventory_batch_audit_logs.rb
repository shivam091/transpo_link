# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryBatchAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_batch_audit_logs, id: :uuid do |t|
      t.references :inventory_batch,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventory_batches,
                     name: :fk_inventory_batch_audit_logs_inventory_batch_id_on_inventory_batches,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :previous_quantity, precision: 12, scale: 2, default: 0.0
      t.decimal :new_quantity, precision: 12, scale: 2, default: 0.0
      t.jsonb :metadata, default: {}, index: {using: :gin}
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_inventory_batch_audit_logs_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.index [:inventory_batch_id, :user_id], using: :btree

      t.check_constraint "previous_quantity IS NOT NULL", name: :check_inventory_batch_audit_logs_previous_quantity_presence
      t.check_constraint "new_quantity IS NOT NULL", name: :check_inventory_batch_audit_logs_new_quantity_presence
    end
  end
end
