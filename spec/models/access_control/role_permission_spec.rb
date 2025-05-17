# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/access_control/role_permission_spec.rb

require "spec_helper"

RSpec.describe AccessControl::RolePermission, type: :model do
  subject(:role_permission) { build(:role_permission) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:role_permission) }
  end

  describe "validations" do
    describe "#role_id" do
      let!(:role_permission) { create(:role_permission) }

      it { is_expected.to validate_presence_of(:role_id) }
      it { is_expected.to validate_uniqueness_of(:role_id).scoped_to(:permission_id).case_insensitive }
    end

    describe "#permission_id" do
      it { is_expected.to validate_presence_of(:permission_id) }
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:role).inverse_of(:role_permissions) }
    it { is_expected.to belong_to(:permission).class_name("AccessControl::Permission").inverse_of(:role_permissions) }
  end
end
