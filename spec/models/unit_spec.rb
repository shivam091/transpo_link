# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/unit_spec.rb

require "spec_helper"

RSpec.describe Unit, type: :model do
  subject(:unit) { build(:unit) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:item_unit) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:category).backed_by_column_of_type(:enum).with_prefix }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(Pageable) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:symbol) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "associations" do
    it { is_expected.to have_many(:source_conversions).with_foreign_key(:source_unit_id).inverse_of(:source_unit).class_name("UnitConversion").dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:target_conversions).with_foreign_key(:target_unit_id).inverse_of(:target_unit).class_name("UnitConversion").dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:warehouses).inverse_of(:unit).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:products).inverse_of(:unit).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:inventories).inverse_of(:unit).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:inventory_batches).inverse_of(:unit).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:inventory_movements).inverse_of(:unit).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:purchase_order_items).inverse_of(:unit).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:product_prices).inverse_of(:unit).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:delivered_po_items).inverse_of(:unit).class_name("PurchaseOrderItem::Delivery").dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:restocks).inverse_of(:unit).class_name("Inventory::Restock").dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:stock_adjustments).inverse_of(:unit).dependent(:restrict_with_exception) }
  end

  describe "validations" do
    describe "#category" do
      it { is_expected.to validate_presence_of(:category) }

      context "when category is valid" do
        it "is valid" do
          described_class.categories.keys.each do |category|
            expect(build(:unit, category:)).to be_valid
          end
        end
      end

      context "when category is invalid" do
        it "is invalid" do
          expect {
            build(:unit, category: "invalid_category")
          }.to raise_error(ArgumentError, /is not a valid category/)
        end
      end
    end

    describe "#symbol" do
      let!(:unit) { create(:unit) }

      it { is_expected.to validate_presence_of(:symbol) }
      it { is_expected.to validate_uniqueness_of(:symbol).scoped_to(:category).with_message("already exists for the selected category") }
    end
  end

  describe "class methods and scopes" do
    let!(:item_unit) { create(:item_unit) }
    let!(:dozen_unit) { create(:dozen_unit) }
    let!(:kilogramme_unit) { create(:kilogramme_unit) }

    describe ".for_category" do
      let(:result) { described_class.for_category("count") }

      it "returns units for the specified category only" do
        expect(result).to include(item_unit)
        expect(result).not_to include(kilogramme_unit)
      end
    end

    describe ".select_options" do
      context "when category is provided" do
        let(:result) { described_class.select_options("count") }

        it "returns units grouped by that category only" do
          expect(result.keys).to eq(["count"])
          expect(result["count"]).to match_array([item_unit, dozen_unit])
          expect(result["count"]).not_to include(kilogramme_unit)
          expect(result["weight"]).to be_nil
        end
      end

      context "when category is not provided" do
        let(:result) { described_class.select_options }

        it "returns all units grouped by category" do
          expect(result.keys).to match_array(["count", "weight"])
          expect(result["count"]).to match_array([item_unit, dozen_unit])
          expect(result["weight"]).to match_array([kilogramme_unit])
        end
      end
    end

    describe ".symbols" do
      it "returns array of symbols" do
        expect(described_class.symbols).to match_array(["dz", "item", "kg"])
      end
    end
  end
end
