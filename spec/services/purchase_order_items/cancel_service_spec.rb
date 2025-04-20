# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_item_items/cancel_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::CancelService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  subject(:service_response) { described_class.(purchase_order_item) }

  describe ".call" do
    context "when cancellation is successful" do
      it "transitions the purchase order item to cancelled" do
        expect { service_response }.to change { purchase_order_item.reload.status }.to("cancelled")
      end

      include_examples "returns a success response"
    end

    context "when cancellation fails" do
      before { allow(purchase_order_item).to receive(:cancel!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order item is already cancelled" do
      before { purchase_order_item.cancel! }

      it "does not allow re-cancellation" do
        expect(purchase_order_item).to_not be_may_cancel
        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
