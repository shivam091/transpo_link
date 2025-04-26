# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/reject_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::RejectService, type: :service do
  let!(:purchase_order) { create(:purchase_order, :submitted) }

  subject(:service_response) { described_class.(purchase_order) }

  describe ".call" do
    context "when rejection is successful" do
      it "transitions the purchase order to rejected" do
        expect { service_response }.to change { purchase_order.reload.status }.to("rejected")
      end

      include_examples "returns a success response"
    end

    context "when rejection is unsuccessful" do
      before { allow(purchase_order).to receive(:reject!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order is already rejected" do
      before { purchase_order.reject! }

      it "does not allow re-rejection" do
        expect(purchase_order).to_not be_may_reject
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
