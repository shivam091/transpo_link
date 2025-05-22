# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/purchase_order/rejection_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::Rejection, type: :model do
  subject(:purchase_order_rejection) { build(:purchase_order_rejection) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:purchase_order_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:reason).of_type(:enum) }
    it { is_expected.to have_db_column(:suggested_alternatives).of_type(:text) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:purchase_order_id) }
    it { is_expected.to have_db_index(:reason) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:purchase_order_id).with_name(:po_rejections_purchase_order_id_on_purchase_orders).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_po_rejections_suggested_alternatives_length).with_expression("char_length(suggested_alternatives) <= 1000") }
    it { is_expected.to have_check_constraint(:check_po_rejections_note_length).with_expression("char_length(note) <= 1000") }
    it { is_expected.to have_check_constraint(:check_po_rejections_reason_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_po_rejections_reason_presence).with_expression("reason IS NOT NULL") }
  end
end
