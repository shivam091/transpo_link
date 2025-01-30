# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/role_spec.rb

require "spec_helper"

RSpec.describe Role, type: :model do
  subject(:admin_role) { build(:admin_role) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:admin_role).with_traits(:active) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
  end

  describe "attributes, indexes, and foreign keys" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:name).unique(true) }

    it { is_expected.to have_check_constraint("check_roles_name_length").with_expression("char_length(name::text) <= 55 AND char_length(name::text) >= 2") }
    it { is_expected.to have_check_constraint("check_roles_name_presence").with_expression("name IS NOT NULL AND name::text <> ''::text") }
  end

  describe "default values" do
    it "should set false as default value for #is_active" do
      expect(admin_role.is_active).to be_falsy
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
  end

  describe "validations" do
    describe "#name" do
      it { is_expected.to validate_presence_of(:name).with_message("is required") }
      it { is_expected.to validate_length_of(:name).is_at_least(2).with_message("is too short (minimum is 2 characters)") }
      it { is_expected.to validate_length_of(:name).is_at_most(55).with_message("is too long (maximum is 55 characters)") }
      it { is_expected.to validate_uniqueness_of(:name).with_message("is already in use") }
    end
  end
end
