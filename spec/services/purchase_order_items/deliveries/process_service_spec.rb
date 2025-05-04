# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/deliveries/process_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::Deliveries::ProcessService, type: :service do
  let!(:source_unit) { create(:dozen_unit) }
  let!(:target_unit) { create(:item_unit) }

  let(:inventory) { create(:inventory, unit: target_unit) }
  let(:purchase_order_item) { create(:purchase_order_item, unit: source_unit) }
  let(:delivery) { create(:po_item_delivery, unit: source_unit, purchase_order_item:) }

  subject(:service_response) { described_class.(delivery) }

  describe "#call" do
    context "with mocked services and method calls" do
      before do
        allow(purchase_order_item).to receive(:inventory) { inventory }
        allow_any_instance_of(PurchaseOrderItems::Delivery).to receive(:process_delivery)

        allow(InventoryMovements::PurchaseService).to receive(:call)
        allow(PurchaseOrderItems::UpdateReceivedQuantityService).to receive(:call)
        allow(UnitConversion).to receive(:convert) { 4.0 }
        allow(Replenishments::UpdateService).to receive(:call)
        allow(PurchaseOrderItems::EvaluateDeliveryStatusService).to receive(:call)
      end

      it "calls InventoryMovements::PurchaseService with correct arguments" do
        service_response

        expect(InventoryMovements::PurchaseService).to have_received(:call).with(
          inventory,
          purchase_order_item,
          hash_including(
            quantity: delivery.quantity,
            unit_id: purchase_order_item.unit_id,
            unit_cost: purchase_order_item.unit_cost,
            total_cost: purchase_order_item.total_cost,
            currency: purchase_order_item.currency
          )
        )
      end

      it "calls PurchaseOrderItems::UpdateReceivedQuantityService with correct arguments" do
        service_response

        expect(PurchaseOrderItems::UpdateReceivedQuantityService).to have_received(:call).with(
          purchase_order_item, delivery.quantity
        )
      end

      it "calls UnitConversion with correct units" do
        service_response

        expect(UnitConversion).to have_received(:convert).with(delivery.unit, inventory.unit, delivery.quantity)
      end

      it "calls Replenishments::UpdateService with converted quantity" do
        service_response

        expect(Replenishments::UpdateService).to have_received(:call).with(
          inventory, 4.0, :decrement
        )
      end

      it "calls PurchaseOrderItems::EvaluateDeliveryStatusService" do
        service_response

        expect(PurchaseOrderItems::EvaluateDeliveryStatusService).to have_received(:call).with(
          purchase_order_item
        )
      end
    end
  end
end
