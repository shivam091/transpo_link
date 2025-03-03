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

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Taxable) }
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:tax_number).from("  ABCDE1234a  ").to("ABCDE1234A") }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:tax_details).touch }
  end

  include_examples "apply default scope on created_at:desc"

  describe "validations" do
    describe "#user_id" do
      it { is_expected.to validate_presence_of(:user_id) }
    end

    describe "#tax_number" do
      it { is_expected.to validate_presence_of(:tax_number) }
      it do
        is_expected.to validate_uniqueness_of(:tax_number)
                         .scoped_to([:tax_type, :country])
                         .with_message("should be unique within the same tax type and country")
                         .ignoring_case_sensitivity
      end
    end
  end
end
