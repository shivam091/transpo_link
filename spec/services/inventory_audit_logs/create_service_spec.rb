# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_audit_logs/create_service_spec.rb

require "spec_helper"

RSpec.describe InventoryAuditLogs::CreateService, type: :service do
  let!(:inventory) { create(:inventory) }

  let(:inventory_movement) do
    create(:inventory_movement,
      quantity: 3.0,
      movement_type: :restock,
      inventory: inventory,
      source: inventory
    )
  end

  include_context "with current user"

  subject(:service_response) { described_class.(inventory, inventory_movement) }

  describe ".call" do
    context "when service is called with valid inventory and movement" do
      # Prevent InventoryMovement callback from creating duplicate audit log
      before { allow_any_instance_of(InventoryMovement).to receive(:create_inventory_audit_log) }

      include_examples "creates a record", InventoryAuditLog

      it "sets correct audit log attributes" do
        audit_log = service_response.payload[:inventory_audit_log]

        expect(audit_log.inventory).to eq(inventory)
        expect(audit_log.movement_type).to eq("restock")
        expect(audit_log.previous_quantity).to eq(0.0)
        expect(audit_log.new_quantity).to eq(3.0) # 0.0 + 3.0
        expect(audit_log.metadata).to eq({
          "source" => "Inventory",
          "source_id" => inventory.id
        })
        expect(audit_log.user).to eq(current_user)
      end

      include_examples "returns a success response"
    end

    context "when audit log creation fails due to validation error" do
      before { allow_any_instance_of(InventoryAuditLog).to receive(:save) { false } }

      include_examples "does not change record count", InventoryAuditLog
      include_examples "returns an error response"
    end
  end
end
