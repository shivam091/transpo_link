# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/unit_spec.rb

require "spec_helper"

RSpec.describe Unit, type: :model do
  subject(:unit) { build(:unit) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:category).of_type(:enum) }
    it { is_expected.to have_db_column(:symbol).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:category) }
    it { is_expected.to have_db_index([:category, :symbol]).unique }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_units_category_presence).with_expression("category IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_units_category_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_units_symbol_presence).with_expression("symbol IS NOT NULL AND symbol::text <> ''::text") }
  end
end
