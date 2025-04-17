# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/update_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::UpdateService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item, quantity: 5) }

  subject(:service_response) { described_class.(purchase_order_item, purchase_order_item_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:purchase_order_item_attributes) { {quantity: 10} }

      it "updates the purchase order item" do
        expect { service_response }.to change { purchase_order_item.reload.quantity }.to(10)
      end

      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:purchase_order_item_attributes) { {quantity: nil} }

      it "does not update the purchase order item" do
        expect { service_response }.to not_change { purchase_order_item.reload.quantity }
      end

      include_examples "returns an error response"
    end
  end
end
