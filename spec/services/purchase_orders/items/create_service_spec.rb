# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/items/create_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::Items::CreateService, type: :service do
  let(:product) { create(:product) }

  let!(:purchase_order) { create(:purchase_order) }

  subject(:service_response) { described_class.(purchase_order, purchase_order_item_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:purchase_order_item_attributes) do
        attributes_for(:purchase_order_item,
          product_id: product.id,
          purchase_order_id: purchase_order.id
        )
      end

      include_examples "creates a record", PurchaseOrder::Item
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:purchase_order_item_attributes) do
        attributes_for(:purchase_order_item,
          product_id: nil,
          purchase_order_id: nil
        )
      end

      include_examples "does not change record count", PurchaseOrder::Item
      include_examples "returns an error response"
    end
  end
end
