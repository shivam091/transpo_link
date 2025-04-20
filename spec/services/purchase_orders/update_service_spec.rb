# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/update_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::UpdateService, type: :service do
  let!(:purchase_order) { create(:purchase_order) }

  subject(:service_response) { described_class.(purchase_order, purchase_order_attributes) }

  describe ".call" do
    context "when update is successful" do
      let(:purchase_order_attributes) { {status: "pending"} }

      it "updates the purchase order" do
        expect { service_response }.to change { purchase_order.reload.status }.to("pending")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      let(:purchase_order_attributes) { {status: ""} }

      it "does not update the purchase order" do
        expect { service_response }.to not_change { purchase_order.reload.notes }
      end

      include_examples "returns an error response"
    end
  end
end
