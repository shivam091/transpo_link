# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/legal_identifier_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifier, type: :model do
  subject(:legal_identifier) { build(:legal_identifier, :for_business) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:tax_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:tax_identifier_type).of_type(:string) }
    it { is_expected.to have_db_column(:entity_type).of_type(:enum) }
    it { is_expected.to have_db_column(:business_identifier_type).of_type(:string) }
    it { is_expected.to have_db_column(:business_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index([:tax_identifier, :tax_identifier_type, :country, :entity_type]).unique }
    it { is_expected.to have_db_index([:business_identifier, :business_identifier_type, :country]).unique }
    it { is_expected.to have_db_index(:entity_type) }
    it { is_expected.to have_db_index(:status) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_legal_identifiers_user_id_on_users).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_legal_identifiers_tax_identifier_type_presence).with_expression("tax_identifier_type IS NOT NULL AND tax_identifier_type::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_tax_identifier_presence).with_expression("tax_identifier IS NOT NULL AND tax_identifier::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_country_presence).with_expression("country IS NOT NULL AND country::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_entity_type_presence).with_expression("entity_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_entity_type_in_enum_values).with_expression("entity_type = ANY (ARRAY['business'::entity_types, 'individual'::entity_types])") }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_bi_presence_based_on_entity) }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_bi_type_presence_based_on_entity) }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_status_presence) }
    it { is_expected.to have_check_constraint(:check_legal_identifiers_status_in_enum_values).with_expression("status = ANY (ARRAY['unapproved'::legal_identifier_statuses, 'approved'::legal_identifier_statuses, 'rejected'::legal_identifier_statuses])") }
  end
end
