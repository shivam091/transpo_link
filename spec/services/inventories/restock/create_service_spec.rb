# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/restock/create_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::Restock::CreateService, type: :service do
  let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
  let(:inventory_batch) { create(:inventory_batch, quantity: 100, source: purchase_order_item) }

  subject(:service_response) { described_class.(inventory_batch, restock_attributes) }

  before { allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:restock_attributes) { attributes_for(:inventory_restock) }

      include_examples "creates a record", Inventory::Restock
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:restock_attributes) { attributes_for(:inventory_restock, comment: "") }

      include_examples "does not change record count", Inventory::Restock
      include_examples "returns an error response"
    end
  end
end
