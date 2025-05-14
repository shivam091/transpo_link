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
  end

  include_examples "apply default scope on created_at:desc"
end
