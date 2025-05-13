# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_audit_logs/purchase_service_spec.rb

require "spec_helper"

RSpec.describe InventoryAuditLogs::PurchaseService, type: :service do
  let(:unit) { create(:item_unit) }

  let!(:inventory) { create(:inventory, unit:) }
  let!(:inventory_movement) { create(:inventory_movement, :purchase, unit:, inventory:) }

  subject(:service_response) { described_class.(inventory, inventory_movement) }

  include_context "with current user"

  describe ".call" do
    before { allow_any_instance_of(InventoryMovement).to receive(:create_inventory_audit_log) }

    context "when movement type is purchase" do
      let!(:prior_purchases) do
        create_list(:inventory_movement, 2, :purchase, quantity: 5.0, inventory:, unit:)
      end

      include_examples "creates a record", InventoryAuditLog

      it "sets correct audit log attributes for purchase" do
        inventory_audit_log = service_response.payload[:inventory_audit_log]

        expected_previous_quantity = prior_purchases.sum(&:quantity) # 10.0
        expected_new_quantity = expected_previous_quantity + inventory_movement.quantity # 12.0

        expect(inventory_audit_log.movement_type).to eq("purchase")
        expect(inventory_audit_log.previous_quantity).to eq(expected_previous_quantity)
        expect(inventory_audit_log.new_quantity).to eq(expected_new_quantity)
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
