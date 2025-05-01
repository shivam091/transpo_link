# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryBatchProcessingLogs < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :inventory_batch_processing_logs, id: :uuid do |t|
      t.references :inventory_batch,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventory_batches,
                     name: :fk_inventory_batch_processing_logs_inventory_batch_id_on_inventory_batches,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.enum :status, enum_type: :batch_processing_statuses, index: {using: :btree}
      t.jsonb :error_logs, default: {}, index: {using: :gin}
      t.jsonb :metadata, default: {}, index: {using: :gin}
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_inventory_batch_processing_logs_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.index [:inventory_batch_id, :user_id], using: :btree

      t.check_constraint "status IS NOT NULL", name: :check_inventory_batch_processing_logs_status_presence
      t.check_constraint "status IN (#{enum_values('batch_processing_statuses')})", name: :check_inventory_batch_processing_logs_status_in_enum_values
    end
  end
end
