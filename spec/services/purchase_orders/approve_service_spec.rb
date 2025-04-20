# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/approve_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::ApproveService, type: :service do
  let!(:purchase_order) { create(:purchase_order, :pending) }

  subject(:service_response) { described_class.(purchase_order) }

  describe ".call" do
    context "when approval is successful" do
      it "transitions the purchase order to approved" do
        expect { service_response }.to change { purchase_order.reload.status }.to("approved")
      end

      include_examples "returns a success response"
    end

    context "when approval is unsuccessful" do
      before { allow(purchase_order).to receive(:approve!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order is already approved" do
      before { purchase_order.approve! }

      it "does not allow re-approval" do
        expect(purchase_order).to_not be_may_approve
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
