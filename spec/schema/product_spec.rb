# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/product_spec.rb

require "spec_helper"

RSpec.describe Product, type: :model do
  subject(:product) { build(:product) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:sku).of_type(:string) }
    it { is_expected.to have_db_column(:barcode).of_type(:string) }
    it { is_expected.to have_db_column(:min_stock_threshold).of_type(:decimal).with_options(precision: 12, scale: 2, default: 10.0) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:cost_price).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:product_category_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:sku).unique }
    it { is_expected.to have_db_index(:barcode).unique }
    it { is_expected.to have_db_index(:product_category_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:is_active) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:product_category_id).with_name(:fk_products_product_category_id_on_product_categories).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_products_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_products_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_products_name_length).with_expression("char_length(name::text) <= 255 AND char_length(name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_products_description_length).with_expression("char_length(description) <= 2000") }
    it { is_expected.to have_check_constraint(:check_products_sku_presence).with_expression("sku IS NOT NULL AND sku::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_products_sku_length).with_expression("char_length(sku::text) <= 50") }
    it { is_expected.to have_check_constraint(:check_products_min_stock_threshold_presence).with_expression("min_stock_threshold IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_products_min_stock_threshold_positive).with_expression("min_stock_threshold > 0.0") }
    it { is_expected.to have_check_constraint(:check_products_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_products_cost_price_presence).with_expression("cost_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_products_cost_price_positive).with_expression("cost_price > 0.0") }
  end
end
