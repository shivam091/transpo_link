# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/tax_detail_spec.rb

require "spec_helper"

RSpec.describe TaxDetail, type: :model do
  subject { create(:tax_detail, :for_business) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:tax_detail) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:tax_number).of_type(:string) }
    it { is_expected.to have_db_column(:tax_type).of_type(:enum) }
    it { is_expected.to have_db_column(:entity_type).of_type(:enum) }
    it { is_expected.to have_db_column(:business_number_type).of_type(:enum) }
    it { is_expected.to have_db_column(:business_number).of_type(:string) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index([:tax_number, :tax_type, :country, :entity_type]).unique(true) }
    it { is_expected.to have_db_index([:business_number, :business_number_type, :country]).unique(true) }
    it { is_expected.to have_db_index(:entity_type) }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_tax_details_user_id_on_users).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_tax_details_tax_type_presence).with_expression("tax_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_tax_details_tax_number_presence).with_expression("tax_number IS NOT NULL AND tax_number::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_tax_details_country_presence).with_expression("country IS NOT NULL AND country::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_tax_details_entity_type_presence).with_expression("entity_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_tax_details_tax_type_inclusion) }
    it { is_expected.to have_check_constraint(:check_tax_details_entity_type_inclusion).with_expression("entity_type = ANY (ARRAY['business'::entity_types, 'individual'::entity_types])") }
    it { is_expected.to have_check_constraint(:check_tax_details_business_number_type_inclusion) }
    it { is_expected.to have_check_constraint(:check_tax_details_business_number_based_on_entity) }
    it { is_expected.to have_check_constraint(:check_tax_details_business_number_type_based_on_entity) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Taxable) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:entity_type).backed_by_column_of_type(:enum) }
    it { is_expected.to define_enum_for(:business_number_type).backed_by_column_of_type(:enum) }
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:tax_number).from("  ABCDE1234a  ").to("ABCDE1234A") }
    it { is_expected.to normalize(:business_number).from("  l12345Mh2025llP67890  ").to("L12345MH2025LLP67890") }
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
                         .scoped_to([:tax_type, :country, :entity_type])
                         .with_message("should be unique within the same tax type, country, and entity type")
                         .ignoring_case_sensitivity
      end
    end

    describe "#entity_type" do
      it { is_expected.to validate_presence_of(:entity_type) }
      # it { is_expected.to validate_inclusion_of(:entity_type).in_array(described_class.entity_types.keys) }
    end

    describe "#business_number_type" do
      context "when #entity_type is 'business'" do
        before { allow(subject).to receive(:business?) { true } }

        it { is_expected.to validate_presence_of(:business_number_type) }
        # it { is_expected.to validate_inclusion_of(:business_number_type).in_array(described_class.business_number_types.keys) }
      end

      context "when #entity_type is 'individual'" do
        before { allow(subject).to receive(:individual?) { true } }

        it { is_expected.to validate_absence_of(:business_number_type).with_message("must not be present when entity type is business") }
      end
    end

    describe "#business_number" do
      context "when #entity_type is 'business'" do
        before { allow(subject).to receive(:business?) { true } }

        it { is_expected.to validate_presence_of(:business_number) }
        it do
          is_expected.to validate_uniqueness_of(:business_number)
                        .scoped_to([:business_number_type, :country])
                        .with_message("should be unique within the same business number type and country")
                        .ignoring_case_sensitivity
        end
      end

      context "when #entity_type is 'individual'" do
        before { allow(subject).to receive(:individual?) { true } }

        it { is_expected.to validate_absence_of(:business_number).with_message("must not be present when entity type is business") }
      end
    end
  end
end
