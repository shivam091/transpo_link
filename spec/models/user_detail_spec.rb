# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/user_detail_spec.rb

require "spec_helper"

RSpec.describe UserDetail, type: :model do
  subject(:user_detail) { build(:user_detail) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:user_detail) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:mobile_number).of_type(:string) }
    it { is_expected.to have_db_column(:alternate_contact_number).of_type(:string) }
    it { is_expected.to have_db_column(:alternate_email).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:user_id).unique(true) }
    it { is_expected.to have_db_index(:mobile_number).unique(true) }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_user_details_user_id_on_users).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_user_details_first_name_presence).with_expression("first_name IS NOT NULL AND first_name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_details_last_name_presence).with_expression("last_name IS NOT NULL AND last_name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_details_first_name_length).with_expression("char_length(first_name::text) <= 55 AND char_length(first_name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_last_name_length).with_expression("char_length(last_name::text) <= 55 AND char_length(last_name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_mobile_number_length).with_expression("char_length(mobile_number::text) <= 55 AND char_length(mobile_number::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_alternate_contact_number_length).with_expression("char_length(alternate_contact_number::text) <= 55 AND char_length(alternate_contact_number::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_alternate_email_length).with_expression("char_length(alternate_email::text) <= 55 AND char_length(alternate_email::text) >= 2") }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:user_detail).touch }
  end

  describe "validations" do
    describe "#first_name" do
      it { is_expected.to validate_presence_of(:first_name).with_message("is required") }
      it { is_expected.to validate_length_of(:first_name).is_at_least(2).with_message("is too short (minimum is 2 characters)") }
      it { is_expected.to validate_length_of(:first_name).is_at_most(55).with_message("is too long (maximum is 55 characters)") }
    end

    describe "#last_name" do
      it { is_expected.to validate_presence_of(:last_name).with_message("is required") }
      it { is_expected.to validate_length_of(:last_name).is_at_least(2).with_message("is too short (minimum is 2 characters)") }
      it { is_expected.to validate_length_of(:last_name).is_at_most(55).with_message("is too long (maximum is 55 characters)") }
    end

    describe "#mobile_number" do
      it { is_expected.to validate_length_of(:mobile_number).is_at_least(2).allow_blank.with_message("is too short (minimum is 2 characters)") }
      it { is_expected.to validate_length_of(:mobile_number).is_at_most(55).allow_blank.with_message("is too long (maximum is 55 characters)") }
    end

    describe "#alternate_contact_number" do
      it { is_expected.to validate_length_of(:alternate_contact_number).is_at_least(2).allow_blank.with_message("is too short (minimum is 2 characters)") }
      it { is_expected.to validate_length_of(:alternate_contact_number).is_at_most(55).allow_blank.with_message("is too long (maximum is 55 characters)") }
    end

    describe "#alternate_email" do
      it { is_expected.to validate_length_of(:alternate_email).is_at_least(2).allow_blank.with_message("is too short (minimum is 2 characters)") }
      it { is_expected.to validate_length_of(:alternate_email).is_at_most(55).allow_blank.with_message("is too long (maximum is 55 characters)") }
    end
  end
end
