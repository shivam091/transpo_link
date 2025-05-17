# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/access_control/permission_spec.rb

require "spec_helper"

RSpec.describe AccessControl::RolePermission, type: :model do
  subject(:role_permission) { build(:role_permission) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:role_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:permission_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:is_allowed).of_type(:boolean).with_options(default: true) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:role_id) }
    it { is_expected.to have_db_index(:permission_id) }
    it { is_expected.to have_db_index(:is_allowed) }
    it { is_expected.to have_db_index(:is_active) }
    it { is_expected.to have_db_index([:role_id, :permission_id]).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:permission_id).with_name(:fk_access_control_role_permissions_permission_id_on_permissions).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:role_id).with_name(:fk_access_control_role_permissions_action_id_on_roles).on_delete(:restrict) }
  end
end
