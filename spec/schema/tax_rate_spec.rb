# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/tax_rate_spec.rb

require "spec_helper"

RSpec.describe TaxRate, type: :model do
  subject(:tax_rate) { build(:tax_rate) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:tax_identifier_type).of_type(:string) }
    it { is_expected.to have_db_column(:tax_type).of_type(:enum) }
    it { is_expected.to have_db_column(:business_category).of_type(:enum) }
    it { is_expected.to have_db_column(:rate).of_type(:decimal).with_options(precision: 5, scale: 2) }
    it { is_expected.to have_db_column(:valid_from).of_type(:date) }
    it { is_expected.to have_db_column(:valid_to).of_type(:date) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:tax_type) }
    it { is_expected.to have_db_index(:valid_from) }
    it { is_expected.to have_db_index(:valid_to) }
    it { is_expected.to have_db_index(:business_category) }
    it { is_expected.to have_db_index([:country, :tax_identifier_type]) }
    it { is_expected.to have_db_index([:tax_identifier_type, :country, :tax_type, :business_category, :valid_from]).unique }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_tax_rates_country_presence).with_expression("country IS NOT NULL AND country::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_tax_rates_tax_identifier_type_presence).with_expression("tax_identifier_type IS NOT NULL AND tax_identifier_type::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_tax_rates_tax_type_presence).with_expression("tax_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_tax_rates_tax_type_in_enum_values).with_expression("tax_type = ANY (ARRAY['exclusive'::tax_types, 'inclusive'::tax_types])") }
    it { is_expected.to have_check_constraint(:check_tax_rates_business_category_presence).with_expression("business_category IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_tax_rates_business_category_in_enum_values).with_expression("business_category = ANY (ARRAY['b2b'::business_categories, 'b2c'::business_categories])") }
    it { is_expected.to have_check_constraint(:check_tax_rates_rate_presence).with_expression("rate IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_tax_rates_rate_range).with_expression("rate >= 0.0 AND rate <= 100.0") }
    it { is_expected.to have_check_constraint(:check_tax_rates_valid_from_presence).with_expression("valid_from IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_tax_rates_valid_from_today_or_in_future).with_expression("valid_from >= CURRENT_DATE") }
    it { is_expected.to have_check_constraint(:check_tax_rates_valid_to_after_valid_from).with_expression("valid_to IS NULL OR valid_to > valid_from") }
  end
end
