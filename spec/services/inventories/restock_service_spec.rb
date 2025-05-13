# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/restock_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::RestockService, type: :service do
  let(:unit) { create(:item_unit) }
  let(:inventory) { create(:inventory, unit:) }
  let(:purchase_order_item) { create(:purchase_order_item, :delivered, unit:) }
  let(:inventory_batch) { create(:inventory_batch, quantity: 10, source: purchase_order_item, unit:, inventory:) }
  let(:restock) { create(:inventory_restock, quantity: 10, inventory_batch:, unit:) }

  subject(:service_response) { described_class.(inventory_batch, restock) }

  describe ".call" do
    before do
      allow(purchase_order_item).to receive(:inventory) { inventory }

      # Stub callbacks
      allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs)
      allow_any_instance_of(Inventory::Restock).to receive(:restock_inventory)
    end

    context "with actual service and method calls" do
      include_context "with current user"

      it "restocks the inventory and updates the stock" do
        expect {
          service_response
        }.to change { InventoryMovement.count }.by(1)
        .and change { inventory.stock.reload.quantity_in_hand }.by(10)
        .and change { inventory_batch.stock.reload.restocked_quantity }.by(10)
        .and change { inventory_batch.stock.reload.restockable_quantity }.by(-10)
      end
    end

    context "with mocked service and method calls" do
      let(:inventory_movement) { instance_double(InventoryMovement, quantity: 10.0) }

      before do
        allow(inventory_batch).to receive(:restocked_quantity) { 5.0 }

        allow(InventoryMovements::RestockService).to receive(:call) {
          ServiceResponse.success(payload: {inventory_movement: inventory_movement})
        }

        allow(Stocks::UpdateService).to receive(:call)
        allow(InventoryBatches::Stocks::UpdateService).to receive(:call)
      end

      it "calls InventoryMovements::RestockService with correct arguments" do
        service_response

        expect(InventoryMovements::RestockService).to have_received(:call).with(
          inventory,
          restock,
          hash_including(
            quantity: restock.quantity,
            unit: restock.unit,
            unit_cost: inventory_batch.cost_price,
            total_cost: inventory_batch.source.total_cost,
            currency: inventory_batch.currency
          )
        )
      end

      it "calls Stocks::UpdateService with increment and correct quantity" do
        service_response

        expect(Stocks::UpdateService).to have_received(:call).with(
          inventory,
          {quantity_in_hand: inventory_movement.quantity},
          :increment
        )
      end

      it "calls InventoryBatches::Stocks::UpdateService with updated restocked_quantity" do
        service_response

        expect(InventoryBatches::Stocks::UpdateService).to have_received(:call).with(
          inventory_batch,
          {restocked_quantity: 15.0} # 10.0 + 5.0
        )
      end
    end
  end
end
