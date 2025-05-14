# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/purchase_order_item_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItem, type: :model do
  subject(:purchase_order_item) { build(:purchase_order_item) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:purchase_order_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:received_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:unit_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:total_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:quantity) }
    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:purchase_order_id) }
    it { is_expected.to have_db_index(:received_quantity) }
    it { is_expected.to have_db_index(:status) }
    it { is_expected.to have_db_index([:purchase_order_id, :product_id]).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:purchase_order_id).with_name(:fk_purchase_order_items_purchase_order_id_on_purchase_orders).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_purchase_order_items_product_id_on_products).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_purchase_order_items_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_purchase_order_items_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_quantity_presence).with_expression("quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_received_quantity_non_negative).with_expression("received_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_received_quantity_presence).with_expression("received_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_status_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_status_presence).with_expression("status IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_unit_cost_positive).with_expression("unit_cost > 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_unit_cost_presence).with_expression("unit_cost IS NOT NULL") }
  end
end
