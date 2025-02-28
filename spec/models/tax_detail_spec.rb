# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/tax_detail_spec.rb

require "spec_helper"

RSpec.describe TaxDetail, type: :model do
  subject { build(:tax_detail) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:tax_detail) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:tax_number).of_type(:string) }
    it { is_expected.to have_db_column(:tax_type).of_type(:enum) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index([:tax_number, :tax_type, :country]).unique(true) }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_tax_details_user_id_on_users).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_tax_details_tax_type_presence).with_expression("tax_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_tax_details_tax_number_presence).with_expression("tax_number IS NOT NULL AND tax_number::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_tax_details_tax_type_inclusion) }
    it { is_expected.to have_check_constraint(:check_tax_details_tax_type_requires_country) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:tax_type).backed_by_column_of_type(:enum) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:INTERNATIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:REGIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:NATIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:COUNTRY_REQUIRING_TAX_TYPES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Pageable) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:tax_details).touch }
  end

  include_examples "apply default scope on created_at:desc"

  describe "validations" do
    describe "#user_id" do
      it { is_expected.to validate_presence_of(:user_id) }
    end

    describe "#tax_type" do
      it { is_expected.to validate_presence_of(:tax_type) }
    end

    describe "#tax_number" do
      it { is_expected.to validate_presence_of(:tax_number) }
      it do
        is_expected.to validate_uniqueness_of(:tax_number)
                         .scoped_to([:tax_type, :country])
                         .with_message("should be unique within the same tax type and country")
      end
    end

    describe "#country" do
      context "when #tax_type requires the country" do
        before { allow(subject).to receive(:requires_country?) { true } }

        it { is_expected.to validate_presence_of(:country) }
      end

      context "when #tax_type does not require the country" do
        before { allow(subject).to receive(:requires_country?) { false } }

        it { is_expected.not_to validate_presence_of(:country) }
      end
    end
  end
end
