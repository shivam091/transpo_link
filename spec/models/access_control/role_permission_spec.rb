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
    it { is_expected.to belong_to(:role).inverse_of(:role_permissions).touch }
    it { is_expected.to belong_to(:permission).class_name("AccessControl::Permission").inverse_of(:role_permissions) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:module).to(:permission) }
    it { is_expected.to delegate_method(:action).to(:permission) }
  end

  describe "class methods & scopes" do
    let!(:module_a) { create(:module, label_key: "module_a", position: 2) }
    let!(:module_b) { create(:module, label_key: "module_b", position: 1) }

    let!(:action_a) { create(:action, label_key: "action_a") }
    let!(:action_b) { create(:action, label_key: "action_b") }

    let!(:permission_aa) { create(:permission, module: module_a, action: action_a, position: 1) }
    let!(:permission_ab) { create(:permission, module: module_a, action: action_b, position: 2) }
    let!(:permission_ba) { create(:permission, module: module_b, action: action_a, position: 1) }

    let!(:role) { create(:manager_role) }

    let!(:rp_aa) { create(:role_permission, permission: permission_aa, role:) }
    let!(:rp_ab) { create(:role_permission, permission: permission_ab, role:) }
    let!(:rp_ba) { create(:role_permission, permission: permission_ba, role:) }

    describe ".ordered_by_positions" do
      let(:ordered) { described_class.ordered_by_positions }

      it "returns role permissions ordered by module position and then permission position" do
        expect(ordered).to eq([rp_ba, rp_aa, rp_ab])
      end
    end

    describe ".grouped_by_module" do
      let(:grouped) { described_class.grouped_by_module }

      it "groups role permissions by their associated module" do
        expect(grouped.keys).to match_array([module_a, module_b])
        expect(grouped[module_a]).to contain_exactly(rp_aa, rp_ab)
        expect(grouped[module_b]).to contain_exactly(rp_ba)
      end
    end
  end

  describe "instance methods" do
    describe "#invalidate_cache" do
      let(:role) { create(:manager_role) }
      let(:permission) { create(:permission) }
      let(:role_permission) { build(:role_permission, role:, permission:) }

      it "deletes the cache key for user_permissions and role_id", transactional: false do
        cache_key = ["user_permissions", role.id]
        Rails.cache.write(cache_key, "cached_permissions")

        expect(Rails.cache.read(cache_key)).to eq("cached_permissions")

        role_permission.save!
        role_permission.send(:invalidate_cache)

        expect(Rails.cache.read(cache_key)).to be_nil
      end
    end
  end
end
