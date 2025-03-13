# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/product_spec.rb

require "spec_helper"

RSpec.describe Product, type: :model do
  subject { create(:product) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:product) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:sku).of_type(:string) }
    it { is_expected.to have_db_column(:barcode).of_type(:string) }
    it { is_expected.to have_db_column(:min_stock_threshold).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:capacity_unit).of_type(:string) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:cost_price).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:product_category_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:sku).unique }
    it { is_expected.to have_db_index(:barcode).unique }
    it { is_expected.to have_db_index(:product_category_id) }
    it { is_expected.to have_db_index(:is_active) }

    it { is_expected.to have_foreign_key(:product_category_id).with_name(:fk_products_product_category_id_on_product_categories).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_products_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_products_name_length).with_expression("char_length(name::text) <= 255 AND char_length(name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_products_description_length).with_expression("char_length(description) <= 2000") }
    it { is_expected.to have_check_constraint(:check_products_sku_presence).with_expression("sku IS NOT NULL AND sku::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_products_sku_length).with_expression("char_length(sku::text) <= 50") }
    it { is_expected.to have_check_constraint(:check_products_min_stock_threshold_presence).with_expression("min_stock_threshold IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_products_min_stock_threshold_numericality).with_expression("min_stock_threshold >= 0") }
    it { is_expected.to have_check_constraint(:check_products_capacity_unit_presence).with_expression("capacity_unit IS NOT NULL AND capacity_unit::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_products_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_products_cost_price_presence).with_expression("cost_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_products_cost_price_numericality).with_expression("cost_price >= 0.0") }
  end

  describe "default values" do
    let(:product) { described_class.new }

    it "should set 0 as default value for #min_stock_threshold" do
      expect(product.min_stock_threshold).to eq(0)
    end

    it "should set 0.0 as default value for #cost_price" do
      expect(product.cost_price).to eq(0.0)
    end

    it "should set Money's default currency as default value for #currency" do
      expect(product.currency).to eq(Money.default_currency.iso_code)
    end

    it "should set false as default value for #is_active" do
      expect(product.is_active).to be_falsy
    end
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sortable) }
  end

  describe "associations" do
    it { is_expected.to have_many(:inventories).inverse_of(:product).dependent(:destroy) }
    it { is_expected.to have_many(:product_prices).inverse_of(:product).dependent(:destroy) }
    it { is_expected.to have_many(:unit_conversions).inverse_of(:product).dependent(:destroy) }

    it { is_expected.to belong_to(:product_category).inverse_of(:products).counter_cache }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:product_category).with_prefix }
  end

  include_examples "apply default scope on created_at:desc"
end
