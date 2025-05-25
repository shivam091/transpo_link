# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreatePurchaseOrderApprovals < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :purchase_order_approvals, id: :uuid do |t|
      t.references :purchase_order,
                   type: :uuid,
                   foreign_key: {
                     to_table: :purchase_orders,
                     name: :fk_po_approvals_purchase_order_id_on_purchase_orders,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_po_approvals_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.string :reference_document, index: {using: :btree}
      t.date :expected_delivery_date, index: {using: :btree}
      t.enum :incoterm_code, enum_type: :incoterm_codes
      t.enum :shipping_method, enum_type: :shipping_methods
      t.text :payment_terms
      t.text :remarks
      t.boolean :partial_delivery_allowed, default: true
      t.timestamps_with_timezone null: false

      t.check_constraint "reference_document IS NOT NULL AND reference_document <> ''", name: :check_po_approvals_reference_document_presence
      t.check_constraint "CHAR_LENGTH(reference_document) <= 55", name: :check_po_approvals_reference_document_length

      t.check_constraint "expected_delivery_date IS NOT NULL", name: :check_po_approvals_expected_delivery_presence
      t.check_constraint "expected_delivery_date >= CURRENT_DATE", name: :check_po_approvals_expected_delivery_today_or_in_future
      t.check_constraint "expected_delivery_date <= CURRENT_DATE + INTERVAL '180 days'", name: :check_po_approvals_expected_delivery_max_6_months

      t.check_constraint "incoterm_code IS NOT NULL", name: :check_po_approvals_incoterm_code_presence
      t.check_constraint "incoterm_code IN (#{enum_values('incoterm_codes')})", name: :check_po_approvals_incoterm_code_in_enum_values

      t.check_constraint "shipping_method IS NOT NULL", name: :check_po_approvals_shipping_method_presence
      t.check_constraint "shipping_method IN (#{enum_values('shipping_methods')})", name: :check_po_approvals_shipping_method_in_enum_values

      t.check_constraint "payment_terms IS NOT NULL AND payment_terms <> ''", name: :check_po_approvals_payment_terms_presence
      t.check_constraint "CHAR_LENGTH(payment_terms) <= 1000", name: :check_po_approvals_payment_terms_length

      t.check_constraint "CHAR_LENGTH(remarks) <= 1000", name: :check_po_approvals_remarks_length
    end
  end
end
