# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/items/evaluate_delivery_status_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::Items::EvaluateDeliveryStatusService, type: :service do
  let(:purchase_order_item) { create(:purchase_order_item, quantity: ordered_quantity, received_quantity: received_quantity) }

  subject(:service_response) { described_class.(purchase_order_item) }

  describe ".call" do
    context "when total received quantity equals ordered quantity" do
      let(:ordered_quantity) { 5 }
      let(:received_quantity) { 5 }

      it "calls PurchaseOrders::Items::DeliverService" do
        expect(PurchaseOrders::Items::DeliverService)
          .to receive(:call)
          .with(purchase_order_item)
          .and_call_original

        service_response
      end
    end

    context "when total received quantity is less than ordered quantity" do
      let(:ordered_quantity) { 5 }
      let(:received_quantity) { 3 }

      it "calls PurchaseOrders::Items::PartiallyDeliverService" do
        expect(PurchaseOrders::Items::PartiallyDeliverService)
          .to receive(:call)
          .with(purchase_order_item)
          .and_call_original

        service_response
      end
    end

    context "when total received quantity greater than ordered quantity" do
      let(:ordered_quantity) { 5 }
      let(:received_quantity) { 6 }

      it "still calls PurchaseOrders::Items::DeliverService" do
        expect(PurchaseOrders::Items::DeliverService)
          .to receive(:call)
          .with(purchase_order_item)
          .and_call_original

        service_response
      end
    end
  end
end
