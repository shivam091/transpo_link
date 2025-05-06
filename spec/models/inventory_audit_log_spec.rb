# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_audit_log_spec.rb

require "spec_helper"

RSpec.describe InventoryAuditLog, type: :model do
  subject(:inventory_audit_log) { build(:inventory_audit_log) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_audit_log) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:inventory_movement_id).of_type(:uuid).with_options(null: true) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:movement_type).of_type(:string) }
    it { is_expected.to have_db_column(:previous_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:new_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:metadata).of_type(:jsonb).with_options(default: "{}") }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index([:inventory_id, :movement_type]) }
    it { is_expected.to have_db_index(:inventory_id) }
    it { is_expected.to have_db_index(:inventory_movement_id) }
    it { is_expected.to have_db_index(:metadata) }
    it { is_expected.to have_db_index(:movement_type) }
    it { is_expected.to have_db_index(:user_id) }

    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_inventory_audit_logs_inventory_id_on_inventories).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:inventory_movement_id).with_name(:fk_inventory_audit_logs_inventory_movement_id_on_inventory_move).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_inventory_audit_logs_user_id_on_users).on_delete(:nullify) }

    it { is_expected.to have_check_constraint(:check_inventory_audit_logs_movement_type_presence).with_expression("movement_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_audit_logs_new_quantity_presence).with_expression("new_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_audit_logs_previous_quantity_presence).with_expression("previous_quantity IS NOT NULL") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory).inverse_of(:inventory_audit_logs) }
    it { is_expected.to belong_to(:inventory_movement).inverse_of(:inventory_audit_logs).optional }
    it { is_expected.to belong_to(:user).inverse_of(:inventory_audit_logs) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :validation, :set_default_attributes) }

    describe "#set_default_attributes" do
      include_context "with current user"

      it "should set current user to audit log" do
        inventory_audit_log.validate

        expect(inventory_audit_log.user).to eq(current_user)
      end
    end
  end

  include_examples "apply default scope on created_at:desc"
end
