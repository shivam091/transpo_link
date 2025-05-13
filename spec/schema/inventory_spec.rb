# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/inventory_spec.rb

require "spec_helper"

RSpec.describe Inventory, type: :model do
  subject(:inventory) { build(:inventory) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:tracking_method).of_type(:enum) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:average_cost_price).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:low_stock_threshold).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:warehouse_id) }
    it { is_expected.to have_db_index([:product_id, :warehouse_id]).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_inventories_product_id_on_products).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_inventories_warehouse_id_on_warehouses).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventories_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_inventories_average_cost_price_non_negative).with_expression("average_cost_price >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventories_average_cost_price_presence).with_expression("average_cost_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventories_low_stock_threshold_positive).with_expression("low_stock_threshold > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventories_low_stock_threshold_presence).with_expression("low_stock_threshold IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_tracking_method_presence).with_expression("tracking_method IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_tracking_method_in_enum_values).with_expression("tracking_method = ANY (ARRAY['fifo'::tracking_methods, 'lifo'::tracking_methods, 'average_cost'::tracking_methods])") }
  end
end
