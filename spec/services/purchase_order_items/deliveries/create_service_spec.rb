# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/deliveries/create_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::Deliveries::CreateService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  subject(:service_response) { described_class.(purchase_order_item, delivery_attributes) }

  describe ".call" do
    before do
      allow_any_instance_of(PurchaseOrderItem::Delivery).to receive(:convert_to_item_unit)
      allow_any_instance_of(PurchaseOrderItem::Delivery).to receive(:process_delivery)
    end

    context "when provided attributes are valid" do
      let(:user) { create(:manager) }
      let(:delivery_attributes) do
        attributes_for(:po_item_delivery, unit_id: purchase_order_item.unit_id, user_id: user.id)
      end

      include_examples "creates a record", PurchaseOrderItem::Delivery
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:delivery_attributes) { attributes_for(:po_item_delivery, unit_id: nil) }

      include_examples "does not change record count", PurchaseOrderItem::Delivery
      include_examples "returns an error response"
    end
  end
end
