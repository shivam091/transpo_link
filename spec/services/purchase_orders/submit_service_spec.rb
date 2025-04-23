# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/submit_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::SubmitService, type: :service do
  let!(:purchase_order) { create(:purchase_order) }

  subject(:service_response) { described_class.(purchase_order) }

  describe ".call" do
    context "when submission is successful" do
      it "transitions the purchase order to pending" do
        expect { service_response }.to change { purchase_order.reload.status }.to("pending")
      end

      include_examples "returns a success response"
    end

    context "when submission is unsuccessful" do
      before { allow(purchase_order).to receive(:submit!) { false } }

      it "does not change the status" do
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end

    context "when purchase order is already submitted (pending)" do
      before { purchase_order.submit! }

      it "does not allow re-submission" do
        expect(purchase_order).to_not be_may_submit
        expect { service_response }.to not_change { purchase_order.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
