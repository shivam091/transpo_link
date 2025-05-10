# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/product_price_spec.rb

require "spec_helper"

RSpec.describe ProductPrice, type: :model do
  subject(:product_price) { build(:product_price) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:product_price) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
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

    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:warehouse_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:effective_period) }
    it { is_expected.to have_db_index("((product_id)::text), currency, ((unit_id)::text), ((COALESCE(warehouse_id, '00000000-0000-0000-0000-000000000000'::uuid))::text), effective_period") }

    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_product_prices_product_id_on_products).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_product_prices_warehouse_id_on_warehouses).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_product_prices_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_product_prices_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_presence).with_expression("min_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_product_prices_min_quantity_positive).with_expression("min_quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_positive).with_expression("unit_price > 0.0") }
    it { is_expected.to have_check_constraint(:check_product_prices_unit_price_presence).with_expression("unit_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_product_prices_effective_period_order).with_expression("lower(effective_period) < upper(effective_period)") }
    it { is_expected.to have_check_constraint(:check_product_prices_effective_period_bounds).with_expression("lower(effective_period) IS NOT NULL AND upper(effective_period) IS NOT NULL") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(ActsAsMoney) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
    it { is_expected.to have_constant(:GLOBAL_WAREHOUSE_ID).with_value("00000000-0000-0000-0000-000000000000") }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:min_quantity) }
    it { is_expected.to apply_scale_to(:unit_price) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:product).inverse_of(:product_prices).touch }
    it { is_expected.to belong_to(:warehouse).inverse_of(:product_prices).optional }
    it { is_expected.to belong_to(:unit).inverse_of(:product_prices) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:warehouse).with_prefix.allow_nil }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :validation, :set_effective_period_from_virtual_attributes) }
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

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#effective_from" do
      context "when effective_from is blank" do
        it "is invalid" do
          product_price.effective_period = nil
          product_price.effective_from = nil

          product_price.validate

          expect(product_price.errors[:effective_from]).to include("is required")
        end
      end

      it { is_expected.to validate_comparison_of(:effective_from).is_greater_than_or_equal_to(Date.current) }
    end

    describe "#effective_until" do
      context "when effective_until is blank" do
        it "is invalid" do
          product_price.effective_period = nil
          product_price.effective_until = nil

          product_price.validate

          expect(product_price.errors[:effective_until]).to include("is required")
        end
      end

      it { is_expected.to validate_comparison_of(:effective_until).is_greater_than_or_equal_to(:effective_from) }
    end
  end

  include_examples "apply default scope on created_at:desc"

  describe "class methods and scopes" do
    describe ".with_normalized_warehouse" do
      let!(:product_price_with_nil_warehouse) { create(:product_price, warehouse_id: nil) }
      let!(:product_price_with_specific_warehouse) { create(:product_price) }

      it "returns product_prices with either nil or matching warehouse_id" do
        result = described_class.with_normalized_warehouse(nil)

        expect(result).to include(product_price_with_nil_warehouse)
        expect(result).not_to include(product_price_with_specific_warehouse)
      end

      it "matches product_prices with provided warehouse_id" do
        result = described_class.with_normalized_warehouse(product_price_with_specific_warehouse.warehouse_id)

        expect(result).to include(product_price_with_specific_warehouse)
        expect(result).not_to include(product_price_with_nil_warehouse)
      end
    end

    describe ".effective_on" do
      let!(:product_price) do
        create(:product_price, effective_period: Date.current..(Date.current + 1.month))
      end

      it "returns the product prices effective on given date" do
        expect(described_class.effective_on(Date.current)).to include(product_price)
        expect(described_class.effective_on(Date.current + 1.month)).to include(product_price)
        expect(described_class.effective_on(Date.yesterday)).to be_empty
      end
    end

    describe ".overlapping_with" do
      let(:unit) { create(:unit) }
      let(:currency) { "USD" }
      let(:product) { create(:product, unit:, currency:) }
      let(:warehouse) { create(:warehouse, unit:) }
      let(:default_attributes) { {product:, warehouse:, unit:, currency:} }

      let!(:existing_product_price) do
        create(:product_price, effective_period: Date.current..(Date.current + 1.month), **default_attributes)
      end

      let(:overlapping_product_price) do
        build(:product_price, effective_period: (Date.current + 15.days)..(Date.current + 45.days), **default_attributes)
      end

      context "when effective_period is nil" do
        it "returns none" do
          allow(existing_product_price).to receive(:effective_period) { nil }

          expect(described_class.overlapping_with(existing_product_price)).to be_empty
        end
      end

      context "when there is an overlapping record" do
        it "returns overlapping records excluding the input record" do
          result = described_class.overlapping_with(overlapping_product_price)

          expect(result).to include(existing_product_price)
          expect(result).not_to include(overlapping_product_price)
        end
      end

      context "when there is no overlap" do
        let(:non_overlapping_record) do
          build(:product_price, effective_period: (Date.today + 2.months)..(Date.today + 3.months), **default_attributes)
        end

        it "does not return non-overlapping records" do
          result = described_class.overlapping_with(non_overlapping_record)

          expect(result).to be_empty
        end
      end

      context "when warehouse is nil" do
        it "returns overlapping records with nil warehouse" do
          allow(overlapping_product_price).to receive(:warehouse) { nil }

          result = described_class.overlapping_with(overlapping_product_price)

          expect(result).to include(existing_product_price)
        end
      end
    end
  end

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

    describe "#effective_from" do
      context "when virtual effective_from is set" do
        let(:product_price) { build(:product_price, effective_from: Date.tomorrow) }

        it "returns the virtual effective_from" do
          expect(product_price.effective_from).to eq(Date.tomorrow)
        end
      end

      context "when effective_from is not set but effective_period is set" do
        let(:range) { Date.today..Date.today + 5 }
        let(:product_price) { build(:product_price, effective_period: range, effective_from: nil) }

        it "returns the beginning of effective_period" do
          expect(product_price.effective_from).to eq(range.begin)
        end
      end
    end

    describe "#effective_until" do
      context "when virtual effective_until is set" do
        let(:product_price) { build(:product_price, effective_until: Date.today + 7) }

        it "returns the virtual effective_until" do
          expect(product_price.effective_until).to eq(Date.today + 7)
        end
      end

      context "when effective_period is open-ended or inclusive" do
        let(:range) { Date.today..(Date.today + 5) }
        let(:product_price) { build(:product_price, effective_period: range, effective_from: nil, effective_until: nil) }

        it "returns the end of the range" do
          expect(product_price.effective_until).to eq(Date.today + 5)
        end
      end

      context "when effective_period is exclusive" do
        let(:range) { (Date.today...(Date.today + 5)) }
        let(:product_price) { build(:product_price, effective_period: range, effective_from: nil, effective_until: nil) }

        it "returns one day before the exclusive end" do
          expect(product_price.effective_until).to eq(Date.today + 4)
        end
      end
    end

    describe "#set_effective_period_from_virtual_fields" do
      let(:from) { Date.today + 1 }
      let(:to) { Date.today + 5 }

      it "sets effective_period from effective_from and effective_until" do
        product_price = build(:product_price, effective_from: from, effective_until: to)

        product_price.validate

        expect(product_price.effective_period).to eq(from..to)
      end
    end
  end
end
