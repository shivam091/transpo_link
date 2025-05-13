# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_batch_audit_logs/create_service_spec.rb

require "spec_helper"

RSpec.describe InventoryBatchAuditLogs::CreateService, type: :service do
  let!(:source) { create(:purchase_order_item, :delivered) }

  subject(:service_response) { described_class.(inventory_batch) }

  before { allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs) }

  include_context "with current user"

  describe ".call" do
    let(:inventory_batch) { create(:inventory_batch, source:) }

    include_examples "creates a record", InventoryBatchAuditLog
  end
end
