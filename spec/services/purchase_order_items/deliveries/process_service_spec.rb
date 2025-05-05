# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/deliveries/process_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::Deliveries::ProcessService, type: :service do
  let!(:source_unit) { create(:dozen_unit) }
  let!(:target_unit) { create(:item_unit) }

  let(:inventory) { create(:inventory, unit: target_unit) }
  let(:item) { create(:purchase_order_item, unit: source_unit) }
  let(:delivery) { create(:po_item_delivery, unit: source_unit, item:) }

  subject(:service_response) { described_class.(delivery) }

  describe "#call" do
    context "with mocked services and method calls" do
      before do
        allow(item).to receive(:inventory) { inventory }
        allow_any_instance_of(PurchaseOrder::Item::Delivery).to receive(:converted_quantity_must_not_exceed_remaining_quantity)
        allow_any_instance_of(PurchaseOrder::Item::Delivery).to receive(:process_delivery)

        allow(Inventories::Movements::PurchaseService).to receive(:call)
        allow(PurchaseOrderItems::UpdateReceivedQuantityService).to receive(:call)
        allow(UnitConversion).to receive(:convert) { 4.0 }
        allow(Replenishments::UpdateService).to receive(:call)
        allow(PurchaseOrderItems::EvaluateDeliveryStatusService).to receive(:call)
      end

      it "calls Inventories::Movements::PurchaseService with correct arguments" do
        service_response

        expect(Inventories::Movements::PurchaseService).to have_received(:call).with(
          inventory,
          item,
          hash_including(
            quantity: delivery.quantity,
            unit_id: item.unit_id,
            unit_cost: item.unit_cost,
            total_cost: item.total_cost,
            currency: item.currency
          )
        )
      end

      it "calls PurchaseOrderItems::UpdateReceivedQuantityService with correct arguments" do
        service_response

        expect(PurchaseOrderItems::UpdateReceivedQuantityService).to have_received(:call).with(item, delivery.quantity)
      end

      it "calls UnitConversion with correct units" do
        service_response

        expect(UnitConversion).to have_received(:convert).with(delivery.unit, inventory.unit, delivery.quantity)
      end

      it "calls Replenishments::UpdateService with converted quantity" do
        service_response

        expect(Replenishments::UpdateService).to have_received(:call).with(inventory, 4.0, :decrement)
      end

      it "calls PurchaseOrderItems::EvaluateDeliveryStatusService" do
        service_response

        expect(PurchaseOrderItems::EvaluateDeliveryStatusService).to have_received(:call).with(item)
      end
    end
  end
end
