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
    it { is_expected.to have_db_column(:min_stock_threshold).of_type(:decimal).with_options(precision: 12, scale: 2, default: 10.0) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:cost_price).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:product_category_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:sku).unique }
    it { is_expected.to have_db_index(:barcode).unique }
    it { is_expected.to have_db_index(:product_category_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:is_active) }

    it { is_expected.to have_foreign_key(:product_category_id).with_name(:fk_products_product_category_id_on_product_categories).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_products_unit_id_on_units).on_delete(:restrict) }

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

  describe "default values" do
    let(:product) { described_class.new }

    it "should set 10.0 as default value for #min_stock_threshold" do
      expect(product.min_stock_threshold).to eq(10.0)
    end
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(ActsAsMoney) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(Navigable) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:description) }
    it { is_expected.to nullify_if_blank(:barcode) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:name) }
    it { is_expected.to sanitize_attribute(:description) }
    it { is_expected.to sanitize_attribute(:sku) }
    it { is_expected.to sanitize_attribute(:barcode) }
  end

  describe "associations" do
    it { is_expected.to have_many(:inventories).inverse_of(:product).dependent(:destroy) }
    it { is_expected.to have_many(:warehouses).through(:inventories).inverse_of(:products) }

    it { is_expected.to have_many(:product_prices).inverse_of(:product).dependent(:destroy) }
    it { is_expected.to have_many(:feedbacks).inverse_of(:reviewable).dependent(:nullify) }
    it { is_expected.to have_many(:purchase_order_items).inverse_of(:product).dependent(:restrict_with_exception) }

    it { is_expected.to belong_to(:product_category).inverse_of(:products).counter_cache }
    it { is_expected.to belong_to(:unit).inverse_of(:products) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:product_category).with_prefix }
    it { is_expected.to delegate_method(:symbol).to(:unit).with_prefix }
    it { is_expected.to delegate_method(:category).to(:unit).with_prefix }
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:product_prices).allow_destroy(true) }
  end

  describe "validations" do
    describe "#name" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(255) }
    end

    describe "#description" do
      it { is_expected.to validate_length_of(:description).is_at_most(2000).allow_blank }
    end

    describe "#sku" do
      it { is_expected.to validate_presence_of(:sku) }
      it { is_expected.to validate_length_of(:sku).is_at_most(50) }
      it { is_expected.to validate_uniqueness_of(:sku) }
    end

    describe "#barcode" do
      it { is_expected.to validate_length_of(:barcode).is_at_most(50).allow_blank }
      it { is_expected.to validate_uniqueness_of(:barcode).case_insensitive }
    end

    describe "#min_stock_threshold" do
      it { is_expected.to validate_presence_of(:min_stock_threshold) }
      it { is_expected.to validate_numericality_of(:min_stock_threshold).is_greater_than(0.0) }
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#cost_price" do
      it { is_expected.to validate_presence_of(:cost_price) }
      it { is_expected.to validate_numericality_of(:cost_price).is_greater_than(0.0) }
    end

    describe "#product_category_id" do
      it { is_expected.to validate_presence_of(:product_category_id) }
    end
  end

  include_examples "apply default scope on created_at:desc"

  describe "instance methods" do
    let!(:product) { create(:product) }

    describe "#reject_product_price?" do
      let!(:product_price) { create(:product_price, product:) }

      context "when creating product prices" do
        context "when valid attributes are provided" do
          it "creates a product price" do
            expect {
              product.update(product_prices_attributes: {0 => {min_quantity: 10, unit_price: 202, currency: "INR"}})
            }.to change(ProductPrice, :count).by(1)
          end
        end

        context "when invalid attributes are provided" do
          it "does not create a product price if required attributes are blank" do
            expect {
              product.update(product_prices_attributes: {0 => {min_quantity: "", unit_price: "", currency: ""}})
            }.to not_change(ProductPrice, :count)
          end
        end
      end

      context "when updating product prices" do
        it "updates the existing product price without changing the count" do
          expect {
            product.update(product_prices_attributes: {id: product_price.id, min_quantity: 10, unit_price: 202, currency: "USD"})
          }.to not_change(ProductPrice, :count)

          expect(product_price.reload.currency).to eq("USD")
        end
      end

      context "when destroying product prices" do
        it "removes the product price when _destroy is set to true" do
          expect {
            product.update(product_prices_attributes: {id: product_price.id, _destroy: true})
          }.to change(ProductPrice, :count).by(-1)
        end
      end
    end
  end

  describe "class methods" do
    describe ".select_options" do
      let!(:product) { create(:product, :active) }

      it "should return array of products for select list" do
        expect(described_class.select_options).to eq([[product.name, product.id]])
      end
    end
  end
end
