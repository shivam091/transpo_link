# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/product/price_spec.rb

require "spec_helper"

RSpec.describe Product::Price, type: :model do
  subject(:product_price) { build(:product_price) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:product_price) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid).with_options(null: true) }
    it { is_expected.to have_db_column(:min_quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_price).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:warehouse_id) }

    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_product_prices_product_id_on_products).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_product_prices_warehouse_id_on_warehouses).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_product_prices_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_presence).with_expression("min_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_positive).with_expression("min_quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_positive).with_expression("unit_price > 0.0") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_presence).with_expression("unit_price IS NOT NULL") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(ActsAsMoney) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:min_quantity) }
    it { is_expected.to apply_scale_to(:unit_price) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:product).inverse_of(:prices).touch }
    it { is_expected.to belong_to(:warehouse).inverse_of(:product_prices).optional }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:warehouse).with_prefix.allow_nil }
  end

  describe "validations" do
    describe "#min_quantity" do
      it { is_expected.to validate_presence_of(:min_quantity) }

      context "when min_quantity is invalid" do
        it "is invalid" do
          product_price.min_quantity = "abcd"
          product_price.validate

          expect(product_price.errors[:min_quantity]).to include("must be greater than 0.0")
        end
      end

      context "when min_quantity <= 0.0" do
        it "is invalid" do
          product_price.min_quantity = 0.0
          product_price.validate

          expect(product_price.errors[:min_quantity]).to include("must be greater than 0.0")
        end
      end

      context "when min_quantity > 0.0" do
        it "is valid" do
          product_price.min_quantity = 1.0
          product_price.validate

          expect(product_price.errors[:min_quantity]).to be_empty
        end
      end
    end

    describe "#unit_price" do
      it { is_expected.to validate_presence_of(:unit_price) }

      context "when unit_price is invalid" do
        it "is invalid" do
          product_price.unit_price = "abcd"
          product_price.validate

          expect(product_price.errors[:unit_price]).to include("must be greater than 0.0")
        end
      end

      context "when unit_price <= 0.0" do
        it "is invalid" do
          product_price.unit_price = 0.0
          product_price.validate

          expect(product_price.errors[:unit_price]).to include("must be greater than 0.0")
        end
      end

      context "when unit_price > 0.0" do
        it "is valid" do
          product_price.unit_price = 1.0
          product_price.validate

          expect(product_price.errors[:unit_price]).to be_empty
        end
      end
    end
  end

  include_examples "apply default scope on created_at:desc"

  describe "instance methods" do
    describe "#warehouse_unit_is_in_product_unit_category" do
      let!(:product) { create(:product) }
      let!(:warehouse) { create(:warehouse) }

      context "when the product unit matches warehouse capacity unit category" do
        let(:product_price) { build(:product_price, warehouse:, product:) }

        it "does not add validation errors" do
          product_price.validate

          expect(product_price.errors[:warehouse_id]).to be_blank
        end
      end

      context "when the product unit does not match warehouse capacity unit category" do
        let!(:litre_unit) { create(:litre_unit) }
        let!(:warehouse) { create(:warehouse, unit: litre_unit) }
        let(:product_price) { build(:product_price, warehouse:, product:) }

        it "adds an error on unit_id" do
          product_price.validate

          expect(product_price.errors[:warehouse_id]).to include("is incompatible with this product due to a capacity unit mismatch")
        end
      end

      context "when warehouse is not present" do
        let(:product_price) { build(:product_price, warehouse: nil, product:) }

        it "skips validation when warehouse is nil" do
          product_price.validate

          expect(product_price.errors[:warehouse_id]).to be_blank
        end
      end
    end
  end
end
