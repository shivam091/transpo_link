# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/purchase_order_item/delivery_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItem::Delivery, type: :model do
  subject(:delivery) { build(:po_item_delivery) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:purchase_order_item_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:comment).of_type(:text) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
    it { is_expected.to have_db_column(:reference_document).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:purchase_order_item_id) }
    it { is_expected.to have_db_index(:unit_id) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:purchase_order_item_id).with_name(:fk_purchase_order_item_deliveries_purchase_order_item_id_on_pur).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_purchase_order_item_deliveries_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_quantity_presence).with_expression("quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_comment_length).with_expression("char_length(comment) <= 1000 AND char_length(comment) > 0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_note_length).with_expression("char_length(note) <= 1000") }
    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_reference_document_length).with_expression("char_length(reference_document::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_comment_presence).with_expression("comment IS NOT NULL AND comment <> ''::text") }
  end
end
