# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/user_detail_spec.rb

require "spec_helper"

RSpec.describe UserDetail, type: :model do
  subject(:user_detail) { build(:user_detail) }

  describe "attributes" do
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:mobile_number).of_type(:string) }
    it { is_expected.to have_db_column(:alternate_contact_number).of_type(:string) }
    it { is_expected.to have_db_column(:alternate_email).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:user_id).unique }
    it { is_expected.to have_db_index(:mobile_number).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_user_details_user_id_on_users).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_user_details_first_name_presence).with_expression("first_name IS NOT NULL AND first_name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_details_last_name_presence).with_expression("last_name IS NOT NULL AND last_name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_details_first_name_length).with_expression("char_length(first_name::text) <= 55 AND char_length(first_name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_last_name_length).with_expression("char_length(last_name::text) <= 55 AND char_length(last_name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_mobile_number_length).with_expression("char_length(mobile_number::text) <= 55 AND char_length(mobile_number::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_alternate_contact_number_length).with_expression("char_length(alternate_contact_number::text) <= 55 AND char_length(alternate_contact_number::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_alternate_email_length).with_expression("char_length(alternate_email::text) <= 55 AND char_length(alternate_email::text) >= 2") }
  end
end
