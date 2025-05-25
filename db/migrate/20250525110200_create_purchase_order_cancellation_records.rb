# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreatePurchaseOrderCancellationRecords < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :purchase_order_cancellation_records, id: :uuid do |t|
      t.references :cancellable,
                   type: :uuid,
                   polymorphic: true,
                   null: false,
                   index: {using: :btree, unique: true}
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_po_cancellation_records_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.enum :reason, enum_type: :po_cancellation_reasons, index: {using: :btree}
      t.text :note
      t.timestamps_with_timezone null: false

      t.check_constraint "reason IS NOT NULL", name: :check_po_cancellation_records_reason_presence
      t.check_constraint "reason IN (#{enum_values('po_cancellation_reasons')})", name: :check_po_cancellation_records_reason_in_enum_values

      t.check_constraint "reason != 'OTHER' OR (note IS NOT NULL AND note <> '')", name: :check_po_cancellation_records_note_presence
      t.check_constraint "CHAR_LENGTH(note) <= 1000", name: :check_po_cancellation_records_note_length
    end
  end
end
