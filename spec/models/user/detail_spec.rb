# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/user/detail_spec.rb

require "spec_helper"

RSpec.describe User::Detail, type: :model do
  subject(:user_detail) { build(:user_detail) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:user_detail) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:mobile_number).of_type(:string) }
    it { is_expected.to have_db_column(:alternate_contact_number).of_type(:string) }
    it { is_expected.to have_db_column(:alternate_email).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:user_id).unique }
    it { is_expected.to have_db_index(:mobile_number).unique }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_user_details_user_id_on_users).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_user_details_first_name_presence).with_expression("first_name IS NOT NULL AND first_name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_details_last_name_presence).with_expression("last_name IS NOT NULL AND last_name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_details_first_name_length).with_expression("char_length(first_name::text) <= 55 AND char_length(first_name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_last_name_length).with_expression("char_length(last_name::text) <= 55 AND char_length(last_name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_mobile_number_length).with_expression("char_length(mobile_number::text) <= 55 AND char_length(mobile_number::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_alternate_contact_number_length).with_expression("char_length(alternate_contact_number::text) <= 55 AND char_length(alternate_contact_number::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_user_details_alternate_email_length).with_expression("char_length(alternate_email::text) <= 55 AND char_length(alternate_email::text) >= 2") }
  end

  describe "included modules" do
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(Sanitizable) }
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:first_name).from("  TranspoLink  ").to("TranspoLink") }
    it { is_expected.to normalize(:last_name).from("  User  ").to("User") }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:mobile_number) }
    it { is_expected.to nullify_if_blank(:alternate_contact_number) }
    it { is_expected.to nullify_if_blank(:alternate_email) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:first_name) }
    it { is_expected.to sanitize_attribute(:last_name) }
    it { is_expected.to sanitize_attribute(:mobile_number) }
    it { is_expected.to sanitize_attribute(:alternate_contact_number) }
    it { is_expected.to sanitize_attribute(:alternate_email) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:detail).touch }
  end

  describe "validations" do
    describe "#user_id" do
      it { is_expected.to validate_presence_of(:user_id) }
    end

    describe "#first_name" do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_length_of(:first_name).is_at_least(2).is_at_most(55) }
    end

    describe "#last_name" do
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_length_of(:last_name).is_at_least(2).is_at_most(55) }
    end

    describe "#mobile_number" do
      it { is_expected.to validate_length_of(:mobile_number).is_at_least(2).is_at_most(55).allow_blank }
    end

    describe "#alternate_contact_number" do
      it { is_expected.to validate_length_of(:alternate_contact_number).is_at_least(2).is_at_most(55).allow_blank }
    end

    describe "#alternate_email" do
      it { is_expected.to validate_length_of(:alternate_email).is_at_least(2).is_at_most(55).allow_blank }
    end
  end
end
