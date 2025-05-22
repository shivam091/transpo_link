# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/purchase_order/approval_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::Approval, type: :model do
  subject(:purchase_order_approval) { build(:purchase_order_approval) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:purchase_order_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:reference_document).of_type(:string) }
    it { is_expected.to have_db_column(:expected_delivery_date).of_type(:date) }
    it { is_expected.to have_db_column(:incoterm_code).of_type(:enum) }
    it { is_expected.to have_db_column(:shipping_method).of_type(:enum) }
    it { is_expected.to have_db_column(:payment_terms).of_type(:text) }
    it { is_expected.to have_db_column(:remarks).of_type(:text) }
    it { is_expected.to have_db_column(:partial_delivery_allowed).of_type(:boolean).with_options(default: true) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:purchase_order_id) }
    it { is_expected.to have_db_index(:reference_document) }
    it { is_expected.to have_db_index(:expected_delivery_date) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:purchase_order_id).with_name(:fk_po_approvals_purchase_order_id_on_purchase_orders).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_po_approvals_reference_document_length).with_expression("char_length(reference_document::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_po_approvals_remarks_length).with_expression("char_length(remarks) <= 1000") }
    it { is_expected.to have_check_constraint(:check_po_approvals_expected_delivery_max_6_months).with_expression("expected_delivery_date <= (CURRENT_DATE + 'P180D'::interval)") }
    it { is_expected.to have_check_constraint(:check_po_approvals_expected_delivery_today_or_in_future).with_expression("expected_delivery_date >= CURRENT_DATE") }
    it { is_expected.to have_check_constraint(:check_po_approvals_expected_delivery_presence).with_expression("expected_delivery_date IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_po_approvals_reference_document_presence).with_expression("reference_document IS NOT NULL AND reference_document::text <> ''::text") }

    it { is_expected.to have_check_constraint(:check_po_approvals_payment_terms_length).with_expression("char_length(payment_terms) <= 1000") }
    it { is_expected.to have_check_constraint(:check_po_approvals_incoterm_code_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_po_approvals_incoterm_code_presence).with_expression("incoterm_code IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_po_approvals_payment_terms_presence).with_expression("payment_terms IS NOT NULL AND payment_terms <> ''::text") }
    it { is_expected.to have_check_constraint(:check_po_approvals_shipping_method_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_po_approvals_shipping_method_presence).with_expression("shipping_method IS NOT NULL") }
  end
end
