# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/items/deliver_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::Items::DeliverService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  subject(:service_response) { described_class.(purchase_order_item) }

  describe ".call" do
    context "when delivery is successful" do
      it "transitions the purchase order item to delivered" do
        expect { service_response }.to change { purchase_order_item.reload.status }.to("delivered")
      end

      include_examples "returns a success response"
    end

    context "when delivery is unsuccessful" do
      before { allow(purchase_order_item).to receive(:deliver!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order item is already delivered" do
      before { purchase_order_item.deliver! }

      it "does not allow re-delivery" do
        expect(purchase_order_item).to_not be_may_deliver
        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
