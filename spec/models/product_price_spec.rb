# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/product_price_spec.rb

require "spec_helper"

RSpec.describe ProductPrice, type: :model do
  subject { create(:product_price) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:product_price) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid).with_options(null: true) }
    it { is_expected.to have_db_column(:min_quantity).of_type(:integer).with_options(default: 1) }
    it { is_expected.to have_db_column(:unit_price).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:warehouse_id) }

    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_product_prices_product_id_on_products).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_product_prices_warehouse_id_on_warehouses).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_product_prices_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_presence).with_expression("min_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_numericality).with_expression("min_quantity >= 1") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_presence).with_expression("unit_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_numericality).with_expression("unit_price >= 0.0") }
  end

  describe "default values" do
    let(:product_price) { described_class.new }

    it "should set 1 as default value for #min_quantity" do
      expect(product_price.min_quantity).to eq(1)
    end

    it "should set 0.0 as default value for #unit_price" do
      expect(product_price.unit_price).to eq(0.0)
    end

    it "should set Money's default currency as default value for #currency" do
      expect(product_price.currency).to eq(Money.default_currency.iso_code)
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:product).inverse_of(:product_prices).touch }
    it { is_expected.to belong_to(:warehouse).inverse_of(:product_prices).optional }
  end
end
