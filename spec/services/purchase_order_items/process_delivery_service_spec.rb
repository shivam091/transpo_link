# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/process_delivery_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::ProcessDeliveryService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item, quantity: 5, received_quantity: 2) }
  let(:received_quantity) { 3 }
  let(:inventory) { create(:inventory, product: purchase_order_item.product, warehouse: purchase_order_item.warehouse) }

  subject(:service_response) { described_class.(purchase_order_item, received_quantity) }

  describe ".call" do
    it "calls PurchaseOrderItems::UpdateReceivedQuantityService and updates the received_quantity" do
      expect(PurchaseOrderItems::UpdateReceivedQuantityService)
        .to receive(:call)
        .with(purchase_order_item, received_quantity)
        .and_call_original

      expect {
        service_response
      }.to change { purchase_order_item.reload.received_quantity }.by(received_quantity)
    end

    context "when decrementing replenishment" do
      let(:converted_quantity) { 3.0 }

      before do
        allow_any_instance_of(Warehouse).to receive_message_chain(:inventories, :for_product).and_return(inventory)
        allow(UnitConversion).to receive(:convert)
          .with(purchase_order_item.unit, inventory.unit, received_quantity)
          .and_return(converted_quantity)
        allow(Replenishments::UpdateService).to receive(:call)
      end

      it "converts the quantity and calls Replenishments::UpdateService with :decrement" do
        service_response

        expect(UnitConversion).to have_received(:convert)
          .with(purchase_order_item.unit, inventory.unit, received_quantity)

        expect(Replenishments::UpdateService).to have_received(:call)
          .with(inventory, converted_quantity, :decrement)
      end
    end

    context "when total received quantity equals ordered quantity" do
      it "updates the received_quantity correctly" do
        expect {
          service_response
        }.to change { purchase_order_item.reload.received_quantity }.by(received_quantity)
      end

      it "calls PurchaseOrderItems::DeliverService" do
        expect(PurchaseOrderItems::DeliverService)
          .to receive(:call)
          .with(purchase_order_item)
          .and_call_original

        service_response
      end
    end

    context "when total received quantity is less than ordered quantity" do
      let(:received_quantity) { 2 }

      it "updates the received_quantity correctly" do
        expect {
          service_response
        }.to change { purchase_order_item.reload.received_quantity }.by(received_quantity)
      end

      it "calls PurchaseOrderItems::PartiallyDeliverService" do
        expect(PurchaseOrderItems::PartiallyDeliverService)
          .to receive(:call)
          .with(purchase_order_item)
          .and_call_original

        service_response
      end
    end

    context "when total received quantity greater than ordered quantity" do
      let(:received_quantity) { 5 }

      it "updates the received_quantity correctly" do
        expect {
          service_response
        }.to change { purchase_order_item.reload.received_quantity }.by(3.0)
      end

      it "still calls PurchaseOrderItems::DeliverService" do
        expect(PurchaseOrderItems::DeliverService)
          .to receive(:call)
          .with(purchase_order_item)
          .and_call_original

        service_response
      end
    end

    context "when updating received quantity fails" do
      let(:received_quantity) { 3 }

      before do
        # Simulate the failure of UpdateReceivedQuantityService by returning an error result
        allow(PurchaseOrderItems::UpdateReceivedQuantityService)
          .to receive(:call) { ServiceResponse.error }
      end

      it "does not update the received_quantity" do
        expect {
          service_response
        }.to not_change { purchase_order_item.reload.received_quantity }
      end

      it "does not call PurchaseOrderItems::DeliverService or PurchaseOrderItems::PartiallyDeliverService" do
        # Allow methods to be called so we can spy on them
        allow(PurchaseOrderItems::DeliverService).to receive(:call)
        allow(PurchaseOrderItems::PartiallyDeliverService).to receive(:call)

        service_response

        # Ensure neither DeliverService nor PartiallyDeliverService is called
        expect(PurchaseOrderItems::DeliverService).not_to have_received(:call)
        expect(PurchaseOrderItems::PartiallyDeliverService).not_to have_received(:call)
      end
    end
  end
end
