# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/purchase_order_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder, type: :model do
  subject(:purchase_order) { build(:purchase_order) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:manager_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:supplier_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_document).of_type(:string) }
    it { is_expected.to have_db_column(:order_date).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:expected_delivery_date).of_type(:date) }
    it { is_expected.to have_db_column(:delivered_at).of_type(:date) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:notes).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:manager_id) }
    it { is_expected.to have_db_index(:order_date) }
    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:supplier_id) }
    it { is_expected.to have_db_index(:warehouse_id) }
    it { is_expected.to have_db_index(:status) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:manager_id).with_name(:fk_purchase_orders_manager_id_on_users).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:supplier_id).with_name(:fk_purchase_orders_supplier_id_on_users).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_purchase_orders_warehouse_id_on_warehouses).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_purchase_orders_notes_length).with_expression("char_length(notes) <= 1000") }
    it { is_expected.to have_check_constraint(:check_purchase_orders_reference_document_length).with_expression("char_length(reference_document::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_purchase_orders_expected_delivery_after_order).with_expression("expected_delivery_date >= order_date") }
    it { is_expected.to have_check_constraint(:check_purchase_orders_status_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_purchase_orders_status_presence).with_expression("status IS NOT NULL") }
  end
end
