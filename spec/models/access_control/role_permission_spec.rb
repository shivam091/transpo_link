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

  describe "associations" do
    it { is_expected.to belong_to(:role).inverse_of(:role_permissions) }
    it { is_expected.to belong_to(:permission).class_name("AccessControl::Permission").inverse_of(:role_permissions) }
  end
end
