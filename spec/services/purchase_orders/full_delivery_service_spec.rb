# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/full_delivery_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::FullDeliveryService, type: :service do
  let!(:purchase_order) { create(:purchase_order, :approved) }

  subject(:service_response) { described_class.(purchase_order) }

  describe ".call" do
    context "when full delivery is successful" do
      it "transitions the purchase order to fully_delivered" do
        expect { service_response }.to change { purchase_order.reload.status }.from("approved").to("fully_delivered")
      end

      include_examples "returns a success response"
    end

    context "when full delivery is unsuccessful" do
      before { allow(purchase_order).to receive(:fully_deliver!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order is already fully delivered" do
      before { purchase_order.fully_deliver! }

      it "does not allow re-delivery" do
        expect(purchase_order).to_not be_may_fully_deliver
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
