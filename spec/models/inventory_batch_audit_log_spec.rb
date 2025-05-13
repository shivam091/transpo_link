# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_batch_audit_log_spec.rb

require "spec_helper"

RSpec.describe InventoryBatchAuditLog, type: :model do
  subject(:inventory_batch_audit_log) { build(:inventory_batch_audit_log) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_batch_audit_log) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory_batch).inverse_of(:inventory_batch_audit_logs) }
    it { is_expected.to belong_to(:user).inverse_of(:inventory_batch_audit_logs) }
  end
end
