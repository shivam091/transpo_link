# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/product_spec.rb

require "spec_helper"

RSpec.describe Product, type: :model do
  subject(:product) { build(:product) }

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
    it { is_expected.to include_module(ScaleEnforcer) }
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

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:min_stock_threshold) }
    it { is_expected.to apply_scale_to(:cost_price) }
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
      let!(:product) { create(:product) }

      it { is_expected.to validate_presence_of(:sku) }
      it { is_expected.to validate_length_of(:sku).is_at_most(50) }
      it { is_expected.to validate_uniqueness_of(:sku) }
    end

    describe "#barcode" do
      let!(:product) { create(:product) }

      it { is_expected.to validate_length_of(:barcode).is_at_most(50).allow_blank }
      it { is_expected.to validate_uniqueness_of(:barcode).case_insensitive }
    end

    describe "#min_stock_threshold" do
      it { is_expected.to validate_presence_of(:min_stock_threshold) }

      context "when min_stock_threshold is invalid" do
        it "is invalid" do
          product.min_stock_threshold = "abcd"
          product.validate

          expect(product.errors[:min_stock_threshold]).to include("must be greater than 0.0")
        end
      end

      context "when min_stock_threshold <= 0.0" do
        it "is invalid" do
          product.min_stock_threshold = 0.0
          product.validate

          expect(product.errors[:min_stock_threshold]).to include("must be greater than 0.0")
        end
      end

      context "when min_stock_threshold > 0.0" do
        it "is valid" do
          product.min_stock_threshold = 1.0
          product.validate

          expect(product.errors[:min_stock_threshold]).to be_empty
        end
      end
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#cost_price" do
      it { is_expected.to validate_presence_of(:cost_price) }

      context "when cost_price is invalid" do
        it "is invalid" do
          product.cost_price = "abcd"
          product.validate

          expect(product.errors[:cost_price]).to include("must be greater than 0.0")
        end
      end

      context "when cost_price <= 0.0" do
        it "is invalid" do
          product.cost_price = 0.0
          product.validate

          expect(product.errors[:cost_price]).to include("must be greater than 0.0")
        end
      end

      context "when cost_price > 0.0" do
        it "is valid" do
          product.cost_price = 1.0
          product.validate

          expect(product.errors[:cost_price]).to be_empty
        end
      end
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
              product.update(product_prices_attributes: {0 => {min_quantity: 10, unit_id: product.unit_id, unit_price: 200, currency: "INR", effective_period: Date.current..(Date.current + 1.week)}})
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
            product.update(product_prices_attributes: {id: product_price.id, min_quantity: 10, unit_price: 202, currency: "USD", effective_period: Date.current..(Date.current + 1.month)})
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

    describe "#price_for" do
      let(:unit) { create(:unit) }
      let(:currency) { "USD" }
      let(:warehouse) { create(:warehouse, unit:) }
      let(:default_attributes) { {effective_period: Date.current..(Date.current + 1.month), warehouse:, unit:, currency:} }

      let(:product) do
        create(:product, unit:, currency:).tap do |product|
          create(:product_price, min_quantity: 1, unit_price: 100, product:, **default_attributes)
          create(:product_price, min_quantity: 10, unit_price: 90, product:, **default_attributes)
          create(:product_price, min_quantity: 50, unit_price: 80, product:, **default_attributes)
        end
      end

      context "when matching price tiers exist" do
        it "returns the correct price tier based on quantity" do
          expect(product.price_for(1, warehouse)).to eq(100)
          expect(product.price_for(10, warehouse)).to eq(90)
          expect(product.price_for(50, warehouse)).to eq(80)
          expect(product.price_for(100, warehouse)).to eq(80) # highest tier
        end
      end

      context "when no matching price tier exists for the given warehouse" do
        let(:other_warehouse) { create(:warehouse, unit:) }

        it "returns the product's cost_price" do
          expect(product.price_for(10, other_warehouse)).to eq(product.cost_price)
        end
      end

      context "when memoization is used" do
        it "caches the result for the same input" do
          expect(product.product_prices).to receive(:best_price_for).once.and_call_original

          price1 = product.price_for(10, warehouse)
          price2 = product.price_for(10, warehouse)

          expect(price1).to eq(price2)
        end

        it "caches results separately for different quantity/warehouse combinations" do
          other_warehouse = create(:warehouse, unit:)

          expect(product.product_prices).to receive(:best_price_for).twice.and_call_original

          price1 = product.price_for(10, warehouse)
          price2 = product.price_for(10, other_warehouse)

          expect(price1).not_to eq(price2)
        end

        it "caches results separately for different dates" do
          future_date = Date.current + 1.month

          expect(product.product_prices).to receive(:best_price_for).twice.and_call_original

          price_today = product.price_for(10, warehouse, date: Date.current)
          price_future = product.price_for(10, warehouse, date: future_date)

          expect(price_today).to eq(90)
          expect(price_future).to eq(90)
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
