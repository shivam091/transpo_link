# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/cancel_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::CancelService, type: :service do
  let(:items_count) { 2 }

  let!(:purchase_order) { create(:purchase_order) }
  let!(:purchase_order_items) { create_list(:purchase_order_item, items_count, purchase_order:) }

  subject(:service_response) { described_class.(purchase_order) }

  describe ".call" do
    context "when cancellation is successful" do
      it "transitions the purchase order to cancelled" do
        expect { service_response }.to change { purchase_order.reload.status }.to("cancelled")
      end

      it "calls cancel service on each purchase order item" do
        expect(PurchaseOrders::Items::CancelService).to receive(:call).exactly(items_count).times.and_call_original

        expect {
          service_response
        }.to change {
          purchase_order_items.map { |purchase_order_item| purchase_order_item.reload.status }
        }.from(Array.new(items_count, "pending")).to(Array.new(items_count, "cancelled"))
      end

      include_examples "returns a success response"
    end

    context "when cancellation is unsuccessful" do
      before { allow(purchase_order).to receive(:cancel!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order is already cancelled" do
      before { purchase_order.cancel! }

      it "does not allow re-cancellation" do
        expect(purchase_order).to_not be_may_cancel
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
