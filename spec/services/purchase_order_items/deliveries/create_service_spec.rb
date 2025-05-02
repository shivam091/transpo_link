# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/deliveries/create_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::Deliveries::CreateService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  subject(:service_response) { described_class.(purchase_order_item, delivery_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:delivery_attributes) do
        attributes_for(:po_item_delivery,
          unit_id: purchase_order_item.unit_id,
          quantity: 3.0
        )
      end

      include_examples "creates a record", PurchaseOrderItems::Delivery
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:delivery_attributes) do
        attributes_for(:po_item_delivery, quantity: nil, unit_id: nil)
      end

      include_examples "does not change record count", PurchaseOrderItems::Delivery
      include_examples "returns an error response"
    end
  end
end
