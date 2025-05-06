# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_audit_logs/create_service_spec.rb

require "spec_helper"

RSpec.describe InventoryAuditLogs::CreateService, type: :service do
  let(:source_unit) { create(:dozen_unit) }
  let(:target_unit) { create(:item_unit) }
  let!(:unit_conversion) { create(:dozen_item_conversion, source_unit:, target_unit:) }

  let!(:inventory) { create(:inventory, unit: target_unit) }
  let!(:inventory_movement) { create(:inventory_movement, :purchase, inventory:, unit: target_unit) }

  subject(:service_response) { described_class.(inventory, inventory_movement) }

  describe ".call" do
    context "when movement_type is purchase" do
      before { allow(inventory_movement).to receive(:movement_type) { :purchase } }

      it "calls the PurchaseService" do
        expect(InventoryAuditLogs::PurchaseService).to receive(:call).with(inventory, inventory_movement)

        service_response
      end
    end

    context "when movement_type is restock" do
      before { allow(inventory_movement).to receive(:movement_type) { :restock } }

      it "calls the RestockService" do
        expect(InventoryAuditLogs::RestockService).to receive(:call).with(inventory, inventory_movement)

        service_response
      end
    end

    context "when movement_type is unsupported" do
      before { allow(inventory_movement).to receive(:movement_type) { :unknown_movement_type } }

      it "raises a NotImplementedError" do
        expect { service_response }.to raise_error(NotImplementedError, "Audit log service not implemented for unknown_movement_type")
      end
    end
  end
end
