# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/partially_deliver_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::PartiallyDeliverService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  subject(:service_response) { described_class.(purchase_order_item) }

  describe ".call" do
    context "when partial delivery is successful" do
      it "transitions the purchase order item to partially_delivered" do
        expect { service_response }.to change { purchase_order_item.reload.status }.to("partially_delivered")
      end

      include_examples "returns a success response"
    end

    context "when partial delivery is unsuccessful" do
      before { allow(purchase_order_item).to receive(:partially_deliver!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order item is already partially_delivered" do
      before { allow(purchase_order_item).to receive(:may_partially_deliver?) { false } }

      it "does not allow re-delivery" do
        expect(purchase_order_item).to_not be_may_partially_deliver

        expect { service_response }.to not_change { purchase_order_item.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
