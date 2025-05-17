# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/product_price_spec.rb

require "spec_helper"

RSpec.describe ProductPrice, type: :model do
  subject(:product_price) { build(:product_price) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid).with_options(null: true) }
    it { is_expected.to have_db_column(:min_quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:unit_price).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:effective_period).of_type(:daterange) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:warehouse_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:effective_period) }
    it { is_expected.to have_db_index("((product_id)::text), currency, min_quantity, ((unit_id)::text), ((COALESCE(warehouse_id, '00000000-0000-0000-0000-000000000000'::uuid))::text), effective_period") }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_product_prices_product_id_on_products).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_product_prices_warehouse_id_on_warehouses).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_product_prices_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_product_prices_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_presence).with_expression("min_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_positive).with_expression("min_quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_positive).with_expression("unit_price > 0.0") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_presence).with_expression("unit_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_product_prices_effective_period_order).with_expression("lower(effective_period) < upper(effective_period)") }
    it { is_expected.to have_check_constraint(:check_product_prices_effective_period_bounds).with_expression("lower(effective_period) IS NOT NULL AND upper(effective_period) IS NOT NULL") }
  end
end
