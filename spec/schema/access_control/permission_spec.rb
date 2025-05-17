# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/access_control/permission_spec.rb

require "spec_helper"

RSpec.describe AccessControl::Permission, type: :model do
  subject(:permission) { build(:permission) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:action_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:module_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:position).of_type(:integer) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:action_id) }
    it { is_expected.to have_db_index(:module_id) }
    it { is_expected.to have_db_index(:is_active) }
    it { is_expected.to have_db_index(:position) }
    it { is_expected.to have_db_index([:action_id, :module_id]).unique }
    it { is_expected.to have_db_index([:module_id, :position]).unique }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_access_control_permissions_position_positive).with_expression("\"position\" > 0") }
    it { is_expected.to have_check_constraint(:check_access_control_permissions_position_presence).with_expression("\"position\" IS NOT NULL") }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:action_id).with_name(:fk_access_control_permissions_action_id_on_access_control_actio).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:module_id).with_name(:fk_access_control_permissions_module_id_on_access_control_modul).on_delete(:restrict) }
  end
end
