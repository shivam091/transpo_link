# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/items/update_received_quantity_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::Items::UpdateReceivedQuantityService, type: :service do
  let(:quantity) { 3 }
  let(:max_allowed) { 5 }

  let!(:purchase_order_item) { create(:purchase_order_item, received_quantity: 0, quantity: max_allowed) }

  subject(:service_response) { described_class.(purchase_order_item, quantity) }

  describe ".call" do
    context "when updating is successful" do

      it "updates the received_quantity but not beyond the maximum" do
        expect {
          service_response
        }.to change { purchase_order_item.reload.received_quantity }.by(quantity)
      end

      include_examples "returns a success response"
    end

    context "when updating would exceed maximum quantity" do
      let(:quantity) { 10 } # deliberately more than available

      it "caps the received_quantity at the maximum allowed quantity" do
        expect {
          service_response
        }.to change { purchase_order_item.reload.received_quantity }.to(max_allowed)
      end

      include_examples "returns a success response"
    end

    context "when updating is unsuccessful" do
      before do
        allow(purchase_order_item).to receive(:lock!) { purchase_order_item }
        allow(purchase_order_item).to receive(:update) { false }
      end

      it "does not change received_quantity" do
        expect {
          service_response
        }.to not_change { purchase_order_item.reload.received_quantity }
      end

      include_examples "returns an error response"
    end
  end
end
