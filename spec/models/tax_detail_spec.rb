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

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:business_number) }
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

  describe "#business_number_type_country_combination" do
    let(:tax_detail) do
      build(:tax_detail, :for_business, business_number_type: business_number_type, country: country)
    end

    context "valid business number type and country combinations" do
      where(:business_number_type, :country) do
        described_class::VALID_BUSINESS_NUMBER_TYPE_COUNTRY_COMBINATIONS.flat_map do |type, countries|
          countries.map { |country| [type.to_s, country] }
        end
      end

      with_them do
        it "allows #{params[:business_number_type]} for #{params[:country]}" do
          tax_detail.valid?

          expect(tax_detail.errors[:business_number_type]).to be_empty
        end
      end
    end

    context "when business number type and country combination is invalid" do
      where(:business_number_type, :country) do
        [
          [:ein, "CA"],  # EIN is not valid for CA
          [:duns, "IN"], # DUNS is not valid for IN
          [:cin, "US"],  # CIN is not valid for US
          [:rfc, "AR"],  # RFC is not valid for AR
          [:cuit, "MX"], # CUIT is not valid for MX
          [:ruc, "BR"],  # RUC is not valid for BR
          [:nit, "FR"],  # NIT is not valid for FR
          [:hrb, "GB"],  # HRB is not valid for GB
          [:ogrn, "US"], # OGRN is not valid for US
          [:cr, "DE"]    # CR is not valid for DE
        ]
      end

      with_them do
        it "does not allow #{params[:business_number_type]} for #{params[:country]}" do
          tax_detail.valid?

          expect(tax_detail.errors[:business_number_type]).to include("is not valid for the selected country")
        end
      end
    end
  end
end
