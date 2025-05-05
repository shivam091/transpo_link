# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory/batch/audit_log_spec.rb

require "spec_helper"

RSpec.describe Inventory::Batch::AuditLog, type: :model do
  subject(:inventory_batch_audit_log) { build(:inventory_batch_audit_log) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_batch_audit_log) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:batch_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:previous_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:new_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:metadata).of_type(:jsonb).with_options(default: {}) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:batch_id) }
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index(:metadata) }
    it { is_expected.to have_db_index([:batch_id, :user_id]) }

    it { is_expected.to have_foreign_key(:batch_id).with_name(:fk_inventory_batch_audit_logs_batch_id_on_inventory_batches).on_delete(:nullify) }
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_inventory_batch_audit_logs_user_id_on_users).on_delete(:nullify) }

    it { is_expected.to have_check_constraint(:check_inventory_batch_audit_logs_previous_quantity_presence).with_expression("previous_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_audit_logs_new_quantity_presence).with_expression("new_quantity IS NOT NULL") }
  end

  describe "associations" do
    it { is_expected.to belong_to(:batch).class_name("Inventory::Batch").inverse_of(:audit_logs) }
    it { is_expected.to belong_to(:user).inverse_of(:inventory_batch_audit_logs) }
  end
end
