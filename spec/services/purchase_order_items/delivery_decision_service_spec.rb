# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/delivery_decision_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::ProcessDeliveryService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item, quantity: 5, received_quantity: 2) }

  subject(:service_response) { described_class.(purchase_order_item, received_quantity) }

  describe ".call" do
    context "when total received quantity equals ordered quantity" do
      let(:received_quantity) { 3 }

      it "calls PurchaseOrderItems::DeliverService" do
        # 2 + 3 = 5, equals ordered quantity, so it should call DeliverService
        expect(PurchaseOrderItems::DeliverService)
          .to receive(:call)
          .with(purchase_order_item, received_quantity)
          .and_call_original

        service_response
      end
    end

    context "when total received quantity is less than ordered quantity" do
      let(:received_quantity) { 2 }

      it "calls PurchaseOrderItems::PartiallyDeliverService" do
        # 2 + 2 = 4, less than ordered quantity, so it should call PartiallyDeliverService
        expect(PurchaseOrderItems::PartiallyDeliverService)
          .to receive(:call)
          .with(purchase_order_item, received_quantity)
          .and_call_original

        service_response
      end
    end
  end
end
