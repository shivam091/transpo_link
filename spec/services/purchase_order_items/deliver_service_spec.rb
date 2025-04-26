# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/deliver_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::DeliverService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  let(:quantity) { 3 }

  subject(:service_response) { described_class.(purchase_order_item, quantity) }

  describe ".call" do
    context "when delivery is successful" do
      it "transitions the purchase order item to delivered" do
        expect { service_response }.to change { purchase_order_item.reload.status }.to("delivered")
      end

      it "increments received_quantity" do
        expect { service_response }.to change { purchase_order_item.reload.received_quantity }.by(quantity)
      end

      include_examples "returns a success response"
    end

    context "when delivery is unsuccessful" do
      before { allow(purchase_order_item).to receive(:deliver!).with(quantity) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      it "does not increment received_quantity" do
        expect { service_response }.to not_change { purchase_order_item.reload.received_quantity }
      end

      include_examples "returns an error response"
    end

    context "when purchase order item is already delivered" do
      before { purchase_order_item.deliver!(quantity) }

      it "does not allow re-delivery" do
        expect(purchase_order_item).to_not be_may_deliver
        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
