# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/legal_identifier_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifier, type: :model do
  subject { create(:legal_identifier, :for_business) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:legal_identifier) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:tax_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:tax_identifier_type).of_type(:string) }
    it { is_expected.to have_db_column(:entity_type).of_type(:enum) }
    it { is_expected.to have_db_column(:business_identifier_type).of_type(:string) }
    it { is_expected.to have_db_column(:business_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index([:tax_identifier, :tax_identifier_type, :country, :entity_type]).unique }
    it { is_expected.to have_db_index([:business_identifier, :business_identifier_type, :country]).unique }
    it { is_expected.to have_db_index(:entity_type) }
    it { is_expected.to have_db_index(:status) }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_legal_identifiers_user_id_on_users).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_legal_identifiers_tax_identifier_type_presence).with_expression("tax_identifier_type IS NOT NULL AND tax_identifier_type::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_tax_identifier_presence).with_expression("tax_identifier IS NOT NULL AND tax_identifier::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_country_presence).with_expression("country IS NOT NULL AND country::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_entity_type_presence).with_expression("entity_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_entity_type_inclusion).with_expression("entity_type = ANY (ARRAY['business'::entity_types, 'individual'::entity_types])") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_business_identifier_based_on_entity) }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_business_identifier_type_based_on_entit) }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_status_presence) }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_status_inclusion).with_expression("status = ANY (ARRAY['unapproved'::legal_identifier_statuses, 'approved'::legal_identifier_statuses, 'rejected'::legal_identifier_statuses])") }
  end

  describe "included modules" do
    it { is_expected.to include_module(AASM) }
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Taxable) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(Sanitizable) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:entity_type).backed_by_column_of_type(:enum) }
    it { is_expected.to define_enum_for(:business_identifier_type).backed_by_column_of_type(:string) }
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum) }
  end

  describe "default values" do
    let(:legal_identifier) { described_class.new }

    it "should set unapproved as default value for #status" do
      expect(legal_identifier.status).to eq("unapproved")
    end
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:business_identifier).from("  l12345mh2023PLC000789  ").to("L12345MH2023PLC000789") }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:business_identifier) }
    it { is_expected.to nullify_if_blank(:business_identifier_type) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:tax_identifier) }
    it { is_expected.to sanitize_attribute(:business_identifier) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:BUSINESS_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS) }
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "state machines" do
    it { is_expected.to have_state(:unapproved) }
    it { is_expected.to transition_from(:unapproved).to(:approved).on_event(:approve) }
    it { is_expected.to transition_from(:unapproved).to(:rejected).on_event(:reject) }
    it { is_expected.to_not transition_from(:rejected).to(:approved).on_event(:approve) }
    it { is_expected.to_not transition_from(:approved).to(:rejected).on_event(:reject) }
    it { is_expected.to_not transition_from(:approved).to(:unapproved).on_event(:approve) }
    it { is_expected.to_not transition_from(:rejected).to(:unapproved).on_event(:reject) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:legal_identifiers).touch }
  end

  include_examples "apply default scope on created_at:desc"

  describe "validations" do
    describe "#user_id" do
      it { is_expected.to validate_presence_of(:user_id) }
    end

    describe "#tax_identifier" do
      it { is_expected.to validate_presence_of(:tax_identifier) }
      it do
        is_expected.to validate_uniqueness_of(:tax_identifier)
                         .scoped_to([:tax_identifier_type, :country, :entity_type])
                         .with_message("should be unique within the same tax identifier type, country, and entity type")
                         .ignoring_case_sensitivity
      end
    end

    describe "#entity_type" do
      it { is_expected.to validate_presence_of(:entity_type) }
      # it { is_expected.to validate_inclusion_of(:entity_type).in_array(described_class.entity_types.values) }
    end

    describe "#status" do
      it { is_expected.to validate_presence_of(:status) }
      # it { is_expected.to validate_inclusion_of(:status).in_array(described_class.statuses.values) }
    end

    describe "#business_identifier_type" do
      context "when #entity_type is 'business'" do
        before { allow(subject).to receive(:business?) { true } }

        it { is_expected.to validate_presence_of(:business_identifier_type) }
        # it { is_expected.to validate_inclusion_of(:business_identifier_type).in_array(described_class.business_identifier_types.values) }
      end

      context "when #entity_type is 'individual'" do
        before { allow(subject).to receive(:individual?) { true } }

        it { is_expected.to validate_absence_of(:business_identifier_type).with_message("must not be present when entity type is business") }
      end
    end

    describe "#business_identifier" do
      context "when #entity_type is 'business'" do
        before { allow(subject).to receive(:business?) { true } }

        it { is_expected.to validate_presence_of(:business_identifier) }
        it do
          is_expected.to validate_uniqueness_of(:business_identifier)
                        .scoped_to([:business_identifier_type, :country])
                        .with_message("should be unique within the same business identifier type and country")
                        .ignoring_case_sensitivity
        end
      end

      context "when #entity_type is 'individual'" do
        before { allow(subject).to receive(:individual?) { true } }

        it { is_expected.to validate_absence_of(:business_identifier).with_message("must not be present when entity type is business") }
      end
    end
  end

  describe "#business_identifier_type_country_combination" do
    let(:legal_identifier) do
      build(:legal_identifier, :for_business, business_identifier_type: business_identifier_type, country: country)
    end

    context "when business identifier type and country combination is valid" do
      where(:business_identifier_type, :country) do
        described_class::BUSINESS_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS.flat_map do |type, countries|
          countries.map { |country| [type.to_s, country] }
        end
      end

      with_them do
        it "allows #{params[:business_identifier_type]} for #{params[:country]}" do
          legal_identifier.valid?

          expect(legal_identifier.errors[:business_identifier_type]).to be_empty
        end
      end
    end

    context "when business identifier type and country combination is invalid" do
      where(:business_identifier_type, :country) do
        [
          [:ein, "CA"],  # EIN is not valid for CA
          [:duns, "AT"], # DUNS is not valid for AU
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
        it "does not allow #{params[:business_identifier_type]} for #{params[:country]}" do
          legal_identifier.valid?

          expect(legal_identifier.errors[:business_identifier_type]).to include("is not valid for the selected country")
        end
      end
    end
  end

  describe "class methods" do
    describe ".accessible" do
      it "returns list of accessible legal identifiers" do
        expect(described_class.accessible(subject.user)).to include(subject)
      end
    end
  end
end
