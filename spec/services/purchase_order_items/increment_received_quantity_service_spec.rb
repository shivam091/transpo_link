# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/increment_received_quantity_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::IncrementReceivedQuantityService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  let(:quantity) { 3 }

  subject(:service_response) { described_class.(purchase_order_item, quantity) }

  describe ".call" do
    context "when incrementing is successful" do
      it "increments the received_quantity" do
        expect {
          service_response
        }.to change { purchase_order_item.reload.received_quantity }.by(quantity)
      end

      include_examples "returns a success response"
    end

    context "when incrementing is unsuccessful" do
      before { allow(purchase_order_item).to receive(:increment!) { false } }

      it "does not increment the received_quantity" do
        expect {
          service_response
        }.to not_change { purchase_order_item.reload.received_quantity }
      end

      include_examples "returns an error response"
    end
  end
end
