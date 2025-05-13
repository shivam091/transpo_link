# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/address_spec.rb

require "spec_helper"

RSpec.describe Address, type: :model do
  subject(:address) { build(:address) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:address1).of_type(:string) }
    it { is_expected.to have_db_column(:address2).of_type(:string) }
    it { is_expected.to have_db_column(:city).of_type(:string) }
    it { is_expected.to have_db_column(:state).of_type(:string) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:postal_code).of_type(:string) }
    it { is_expected.to have_db_column(:addressable_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:addressable_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index([:addressable_type, :addressable_id]) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_addresses_address1_presence).with_expression("address1 IS NOT NULL AND address1::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_addresses_country_presence).with_expression("country IS NOT NULL AND country::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_addresses_address1_length).with_expression("char_length(address1::text) <= 100") }
    it { is_expected.to have_check_constraint(:check_addresses_address2_length).with_expression("char_length(address2::text) <= 100") }
    it { is_expected.to have_check_constraint(:check_addresses_postal_code_length).with_expression("char_length(postal_code::text) <= 20") }
  end
end
