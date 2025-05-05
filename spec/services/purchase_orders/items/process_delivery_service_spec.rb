# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/items/process_delivery_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::Items::ProcessDeliveryService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item, quantity: 5, received_quantity: 2) }
  let(:received_quantity) { 3 }

  subject(:service_response) { described_class.(purchase_order_item, received_quantity) }

  describe ".call" do
    it "calls PurchaseOrders::Items::UpdateReceivedQuantityService and updates the received_quantity" do
      expect(PurchaseOrders::Items::UpdateReceivedQuantityService)
        .to receive(:call)
        .with(purchase_order_item, received_quantity)
        .and_call_original

      expect {
        service_response
      }.to change { purchase_order_item.reload.received_quantity }.by(received_quantity)
    end

    context "when total received quantity equals ordered quantity" do
      it "updates the received_quantity correctly" do
        expect {
          service_response
        }.to change { purchase_order_item.reload.received_quantity }.by(received_quantity)
      end

      it "calls PurchaseOrders::Items::DeliverService" do
        expect(PurchaseOrders::Items::DeliverService)
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

      it "calls PurchaseOrders::Items::PartiallyDeliverService" do
        expect(PurchaseOrders::Items::PartiallyDeliverService)
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

      it "still calls PurchaseOrders::Items::DeliverService" do
        expect(PurchaseOrders::Items::DeliverService)
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
        allow(PurchaseOrders::Items::UpdateReceivedQuantityService)
          .to receive(:call) { ServiceResponse.error }
      end

      it "does not update the received_quantity" do
        expect {
          service_response
        }.to not_change { purchase_order_item.reload.received_quantity }
      end

      it "does not call PurchaseOrders::Items::DeliverService or PurchaseOrders::Items::PartiallyDeliverService" do
        # Allow methods to be called so we can spy on them
        allow(PurchaseOrders::Items::DeliverService).to receive(:call)
        allow(PurchaseOrders::Items::PartiallyDeliverService).to receive(:call)

        service_response

        # Ensure neither DeliverService nor PartiallyDeliverService is called
        expect(PurchaseOrders::Items::DeliverService).not_to have_received(:call)
        expect(PurchaseOrders::Items::PartiallyDeliverService).not_to have_received(:call)
      end
    end
  end
end
