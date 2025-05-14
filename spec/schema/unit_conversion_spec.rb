# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/unit_conversion_spec.rb

require "spec_helper"

RSpec.describe UnitConversion, type: :model do
  subject(:unit_conversion) { build(:unit_conversion) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:source_unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:target_unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:multiplier).of_type(:decimal).with_options(precision: 30, scale: 15) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:source_unit_id) }
    it { is_expected.to have_db_index(:target_unit_id) }
    it { is_expected.to have_db_index([:source_unit_id, :target_unit_id]).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:source_unit_id).with_name(:fk_unit_conversions_source_unit_id_on_units).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:target_unit_id).with_name(:fk_unit_conversions_target_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_unit_conversions_multiplier_positive).with_expression("multiplier > 0.0") }
    it { is_expected.to have_check_constraint(:check_unit_conversions_multiplier_presence).with_expression("multiplier IS NOT NULL") }
  end
end
