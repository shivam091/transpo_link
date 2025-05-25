# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreatePurchaseOrderRejections < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :purchase_order_rejections, id: :uuid do |t|
      t.references :purchase_order,
                   type: :uuid,
                   foreign_key: {
                     to_table: :purchase_orders,
                     name: :fk_po_rejections_purchase_order_id_on_purchase_orders,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_po_rejections_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.enum :reason, enum_type: :po_rejection_reasons, index: {using: :btree}
      t.text :suggested_alternatives
      t.text :note
      t.timestamps_with_timezone null: false

      t.check_constraint "reason IS NOT NULL", name: :check_po_rejections_reason_presence
      t.check_constraint "reason IN (#{enum_values('po_rejection_reasons')})", name: :check_po_rejections_reason_in_enum_values

      t.check_constraint "CHAR_LENGTH(suggested_alternatives) <= 1000", name: :check_po_rejections_suggested_alternatives_length

      t.check_constraint "CHAR_LENGTH(note) <= 1000", name: :check_po_rejections_note_length
    end
  end
end
