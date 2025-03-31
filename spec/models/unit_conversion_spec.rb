# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/unit_conversion_spec.rb

require "spec_helper"

RSpec.describe UnitConversion, type: :model do
  subject { build(:unit_conversion) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:unit_conversion) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:from_unit).of_type(:string) }
    it { is_expected.to have_db_column(:to_unit).of_type(:string) }
    it { is_expected.to have_db_column(:conversion_rate).of_type(:decimal).with_options(precision: 10, scale: 4) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index([:product_id, :from_unit, :to_unit]).unique }

    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_unit_conversions_product_id_on_products).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_unit_conversions_conversion_rate_numericality).with_expression("conversion_rate > 0.0") }
    it { is_expected.to have_check_constraint(:check_unit_conversions_conversion_rate_presence).with_expression("conversion_rate IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_unit_conversions_from_unit_presence).with_expression("from_unit IS NOT NULL AND from_unit::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_unit_conversions_to_unit_presence).with_expression("to_unit IS NOT NULL AND to_unit::text <> ''::text") }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:product).inverse_of(:unit_conversions).touch }
  end

  describe "validations" do
    describe "#from_unit" do
      it { is_expected.to validate_presence_of(:from_unit) }
      it { is_expected.to validate_inclusion_of(:from_unit).in_array(TranspoLink::MeasurementUnits.all_units.map(&:to_s)) }
    end

    describe "#to_unit" do
      it { is_expected.to validate_presence_of(:to_unit) }
      it { is_expected.to validate_inclusion_of(:to_unit).in_array(TranspoLink::MeasurementUnits.all_units.map(&:to_s)) }
    end

    describe "#conversion_rate" do
      it { is_expected.to validate_presence_of(:conversion_rate) }
      it { is_expected.to validate_numericality_of(:conversion_rate).is_greater_than(0.0) }
    end
  end

  include_examples "apply default scope on created_at:desc"
end
