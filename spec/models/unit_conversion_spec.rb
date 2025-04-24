# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/unit_conversion_spec.rb

require "spec_helper"

RSpec.describe UnitConversion, type: :model do
  subject { create(:unit_conversion) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:unit_conversion) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:source_unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:target_unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:multiplier).of_type(:decimal).with_options(precision: 30, scale: 15) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:source_unit_id) }
    it { is_expected.to have_db_index(:target_unit_id) }
    it { is_expected.to have_db_index([:source_unit_id, :target_unit_id]).unique }

    it { is_expected.to have_foreign_key(:source_unit_id).with_name(:fk_unit_conversions_source_unit_id_on_units).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:target_unit_id).with_name(:fk_unit_conversions_target_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_unit_conversions_multiplier_positive).with_expression("multiplier > 0.0") }
    it { is_expected.to have_check_constraint(:check_unit_conversions_multiplier_presence).with_expression("multiplier IS NOT NULL") }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Pageable) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:source_unit).class_name("Unit").with_foreign_key(:source_unit_id).inverse_of(:source_conversions) }
    it { is_expected.to belong_to(:target_unit).class_name("Unit").with_foreign_key(:target_unit_id).inverse_of(:target_conversions) }
  end

  describe "validations" do
    describe "#source_unit_id" do
      it { is_expected.to validate_presence_of(:source_unit_id) }
      it { is_expected.to validate_uniqueness_of(:source_unit_id).scoped_to([:target_unit_id]).case_insensitive.with_message("already has conversion for the selected target unit") }
    end

    describe "#target_unit_id" do
      it { is_expected.to validate_presence_of(:target_unit_id) }
    end

    describe "#multiplier" do
      it { is_expected.to validate_presence_of(:multiplier) }
      it { is_expected.to validate_numericality_of(:multiplier).is_greater_than(0.0) }
    end
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:symbol).to(:source_unit).with_prefix }
    it { is_expected.to delegate_method(:symbol).to(:target_unit).with_prefix }
  end

  describe "default scope" do
    let(:sql) { UnitConversion.all.to_sql }

    it "includes join on source_unit and orders by symbol ASC" do
      expect(sql).to match(/ORDER BY \"units\".\"symbol\" ASC/i)
      expect(sql).to include("JOIN")
    end
  end

  describe "class methods" do
    describe ".convert" do
      let(:source_unit) { create(:kilogramme_unit) }
      let(:target_unit) { create(:gramme_unit) }

      context "when source and target units are the same" do
        let(:result) { described_class.convert(source_unit, source_unit, 2) }

        it "returns the same quantity" do
          expect(result).to eq(2)
        end
      end

      context "when conversion exists" do
        let!(:conversion) { create(:kilogramme_gramme_conversion, source_unit:, target_unit:) }

        let(:result) { described_class.convert(source_unit, target_unit, 2) }

        it "returns the converted quantity" do
          expect(result).to eq(2000.0)
        end
      end

      context "when conversion does not exist" do
        let(:result) { described_class.convert(source_unit, target_unit, 2) }

        it "raises UnitConversionError" do
          expect {
            result
          }.to raise_error(UnitConversionError, /Please ensure a valid unit conversion exists./)
        end
      end
    end
  end

  describe "instance methods" do
    let(:source_unit) { build_stubbed(:kilogramme_unit) } # weight
    let(:target_unit) { build_stubbed(:metre_unit) }      # length

    describe "#units_must_be_different" do
      let(:conversion) { build(:unit_conversion, source_unit:, target_unit: source_unit) }

      it "is invalid when source and target units are the same" do
        expect(conversion).to be_invalid
        expect(conversion.errors[:target_unit_id]).to include("must be different from source unit")
      end
    end

    describe "#units_must_have_same_category" do
      let(:conversion) { build(:unit_conversion, source_unit:, target_unit:) }

      it "is invalid when source and target units have different categories" do
        expect(conversion).not_to be_valid
        expect(conversion.errors[:target_unit_id]).to include("must belong to the same category as source unit")
      end
    end
  end
end
