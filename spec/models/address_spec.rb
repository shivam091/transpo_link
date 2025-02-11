# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/address_spec.rb

require "spec_helper"

RSpec.describe Address, type: :model do
  subject(:address) { build(:address) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:address) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:address1).of_type(:string) }
    it { is_expected.to have_db_column(:address2).of_type(:string) }
    it { is_expected.to have_db_column(:city).of_type(:string) }
    it { is_expected.to have_db_column(:state).of_type(:string) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:postal_code).of_type(:string) }
    it { is_expected.to have_db_column(:addressable_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:addressable_type).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_check_constraint("check_addresses_address1_presence").with_expression("address1 IS NOT NULL AND address1::text <> ''::text") }
    it { is_expected.to have_check_constraint("check_addresses_country_presence").with_expression("country IS NOT NULL AND country::text <> ''::text") }
    it { is_expected.to have_check_constraint("check_addresses_address1_length").with_expression("char_length(address1::text) <= 100") }
    it { is_expected.to have_check_constraint("check_addresses_address2_length").with_expression("char_length(address2::text) <= 100") }
    it { is_expected.to have_check_constraint("check_addresses_postal_code_length").with_expression("char_length(postal_code::text) <= 20") }

    it { is_expected.to have_db_index([:addressable_type, :addressable_id]) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:addressable).touch }
  end

  describe "validations" do
    describe "#address1" do
      it { is_expected.to validate_presence_of(:address1).with_message("is required") }
      it { is_expected.to validate_length_of(:address1).is_at_most(100).with_message("is too long (maximum is 100 characters)") }
    end

    describe "#address2" do
      it { is_expected.to validate_length_of(:address2).is_at_most(100).allow_blank.with_message("is too long (maximum is 100 characters)") }
    end

    describe "#postal_code" do
      it { is_expected.to validate_length_of(:postal_code).is_at_most(20).allow_blank.with_message("is too long (maximum is 20 characters)") }
    end

    describe "#country" do
      it { is_expected.to validate_presence_of(:country).with_message("is required") }
    end
  end
end
