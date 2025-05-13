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
    it { is_expected.to belong_to(:user).inverse_of(:user_detail).touch }
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
