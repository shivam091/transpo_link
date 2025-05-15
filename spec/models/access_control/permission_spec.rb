# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/access_control/permission_spec.rb

require "spec_helper"

RSpec.describe AccessControl::Permission, type: :model do
  subject(:permission) { build(:permission) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:permission) }
  end

  describe "associations" do
    it { is_expected.to have_many(:role_permissions).class_name("AccessControl::RolePermission").inverse_of(:permission).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:roles).through(:role_permissions).source(:role) }

    it { is_expected.to belong_to(:action).class_name("AccessControl::Action").inverse_of(:permissions) }
    it { is_expected.to belong_to(:module).class_name("AccessControl::Module").inverse_of(:permissions) }
  end
end
