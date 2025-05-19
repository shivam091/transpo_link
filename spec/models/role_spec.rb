# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/role_spec.rb

require "spec_helper"

RSpec.describe Role, type: :model do
  subject(:role) { build(:admin_role) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:admin_role).with_traits(:active) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
  end

  describe "validations" do
    describe "#name" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(55) }
      it { is_expected.to validate_uniqueness_of(:name) }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:users).inverse_of(:role).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:role_permissions).class_name("AccessControl::RolePermission").inverse_of(:role).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:permissions).through(:role_permissions).class_name("AccessControl::Permission") }
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:role_permissions).allow_destroy(false) }
  end
end
