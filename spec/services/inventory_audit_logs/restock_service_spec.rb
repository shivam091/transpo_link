# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_audit_logs/restock_service_spec.rb

require "spec_helper"

RSpec.describe InventoryAuditLogs::RestockService, type: :service do
  let(:source_unit) { create(:dozen_unit) }
  let(:target_unit) { create(:item_unit) }
  let(:unit_conversion) { create(:dozen_item_conversion, source_unit:, target_unit:) }

  let!(:inventory) { create(:inventory, unit: target_unit) }
  let!(:inventory_movement) do
    create(:inventory_movement,
      :restock,
      quantity: 3.0,
      source: inventory,
      unit: target_unit,
      inventory:
    )
  end

  subject(:service_response) { described_class.(inventory, inventory_movement) }

  include_context "with current user"

  describe ".call" do
    before { allow_any_instance_of(Inventory::Movement).to receive(:create_inventory_audit_log) }

    context "when movement type is restock" do
      include_examples "creates a record", Inventory::AuditLog

      it "sets correct audit log attributes for restock" do
        inventory_audit_log = service_response.payload[:inventory_audit_log]

        expected_previous_quantity = inventory.quantity_in_hand # 0.0
        expected_new_quantity = expected_previous_quantity + inventory_movement.quantity # 3.0

        expect(inventory_audit_log.type).to eq("restock")
        expect(inventory_audit_log.previous_quantity).to eq(expected_previous_quantity)
        expect(inventory_audit_log.new_quantity).to eq(expected_new_quantity)
      end

      include_examples "returns a success response"
    end

    context "when audit log creation fails due to validation error" do
      before { allow_any_instance_of(Inventory::AuditLog).to receive(:save) { false } }

      include_examples "does not change record count", Inventory::AuditLog
      include_examples "returns an error response"
    end
  end
end
