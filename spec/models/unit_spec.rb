# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/unit_spec.rb

require "spec_helper"

RSpec.describe Unit, type: :model do
  subject { create(:unit) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:item_unit) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:category).of_type(:enum) }
    it { is_expected.to have_db_column(:symbol).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:category) }
    it { is_expected.to have_db_index([:category, :symbol]).unique }

    it { is_expected.to have_check_constraint(:check_units_category_presence).with_expression("category IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_units_category_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_units_symbol_presence).with_expression("symbol IS NOT NULL AND symbol::text <> ''::text") }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:category).backed_by_column_of_type(:enum).with_prefix }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:symbol) }
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
  end

  describe "validations" do
    describe "#category" do
      it { is_expected.to validate_presence_of(:category) }
      # it { is_expected.to validate_inclusion_of(:category).in_array(described_class.categories.keys) }
    end

    describe "#symbol" do
      it { is_expected.to validate_presence_of(:symbol) }
      it { is_expected.to validate_uniqueness_of(:symbol).scoped_to(:category).with_message("already exists for the selected category") }
    end
  end

  describe "scopes" do
    describe ".for_category" do
      let!(:count_unit) { create(:item_unit) }
      let!(:weight_unit) { create(:kilogramme_unit) }

      let(:result) { described_class.for_category("count") }

      it "returns units for the specified category only" do
        expect(result).to include(count_unit)
        expect(result).not_to include(weight_unit)
      end
    end
  end

  describe "class methods" do
    let!(:item_unit) { create(:item_unit) }
    let!(:dozen_unit) { create(:dozen_unit) }
    let!(:kilogramme_unit) { create(:kilogramme_unit) }

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
